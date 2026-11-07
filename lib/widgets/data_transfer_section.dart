import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/services/export/export_service.dart';
import 'package:fox/services/import/import_service.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// "Data" section for the view options sheet: export and import.
///
/// Dependencies are injectable so both flows can be widget tested without
/// platform plugins.
class DataTransferSection extends StatefulWidget {
  const DataTransferSection({
    required this.controller,
    required this.settingsService,
    this.exporter,
    this.importer,
    this.outputDirectoryProvider,
    this.backupDirectoryProvider,
    this.shareFile,
    this.pickFiles,
    this.pickFolder,
    super.key,
  });

  final NotesController controller;
  final SettingsService settingsService;
  final FoxExporter? exporter;
  final FoxImporter? importer;
  final Future<Directory> Function()? outputDirectoryProvider;
  final Future<Directory> Function()? backupDirectoryProvider;
  final Future<void> Function(File file)? shareFile;
  final Future<List<ImportFile>> Function()? pickFiles;
  final Future<List<ImportFile>> Function()? pickFolder;

  @override
  State<DataTransferSection> createState() => _DataTransferSectionState();
}

class _DataTransferSectionState extends State<DataTransferSection> {
  bool _exporting = false;
  bool _importing = false;
  ExportProgress? _progress;

  Future<Directory> _defaultDirectory(String name) async {
    final documents = await getApplicationDocumentsDirectory();
    return Directory('${documents.path}/$name');
  }

  Future<List<ImportFile>> _defaultPickFiles() async {
    final result = await FilePicker.pickFiles();
    return [
      for (final file in result)
        ImportFile(name: file.name, bytes: await file.readAsBytes()),
    ];
  }

  Future<List<ImportFile>> _defaultPickFolder() async {
    final path = await FilePicker.getDirectoryPath();
    if (path == null) return const [];
    final files = <ImportFile>[];
    await for (final entity
        in Directory(path).list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final lower = entity.path.toLowerCase();
      if (!(lower.endsWith('.md') ||
          lower.endsWith('.markdown') ||
          lower.endsWith('.txt'))) {
        continue;
      }
      files.add(
        ImportFile(name: entity.path, bytes: await entity.readAsBytes()),
      );
    }
    return files;
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final exporter = widget.exporter ?? FoxExporter();
    final directoryProvider =
        widget.outputDirectoryProvider ?? () => _defaultDirectory('exports');

    setState(() {
      _exporting = true;
      _progress = const ExportProgress(
        completed: 0,
        total: 0,
        stage: 'markdown',
      );
    });

    try {
      final directory = await directoryProvider();
      final result = await exporter.export(
        notes: widget.controller.allNotes,
        folders: widget.controller.folders,
        settings: widget.controller.settingsSnapshot,
        outputDirectory: directory,
        onProgress: (progress) {
          if (mounted) setState(() => _progress = progress);
        },
      );
      if (!mounted) return;
      setState(() => _exporting = false);
      await _share(result.archive);
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.exportComplete(result.noteCount))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _exporting = false);
      await _showError(l10n.exportFailed('$e'));
    }
  }

  Future<void> _import(Future<List<ImportFile>> Function() picker) async {
    if (_importing) return;
    final l10n = AppLocalizations.of(context);
    final backupProvider =
        widget.backupDirectoryProvider ?? () => _defaultDirectory('backups');

    List<ImportFile> files;
    try {
      files = await picker();
    } catch (e) {
      if (mounted) await _showError(l10n.importFailed('$e'));
      return;
    }
    if (files.isEmpty || !mounted) return;

    setState(() => _importing = true);
    try {
      final result = await widget.controller.importFromFiles(
        files: files,
        backupDirectory: await backupProvider(),
        importer: widget.importer,
      );
      if (!mounted) return;
      setState(() => _importing = false);
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.importNotes),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.importSummary(
                  result.added,
                  result.updated,
                  result.skipped,
                ),
              ),
              if (result.backupPath != null) ...[
                const SizedBox(height: 12),
                Text(l10n.importBackupSaved),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        ),
      );
    } on ImportException catch (e) {
      if (!mounted) return;
      setState(() => _importing = false);
      await _showError(l10n.importFailed(e.message));
    } catch (e) {
      if (!mounted) return;
      setState(() => _importing = false);
      await _showError(l10n.importFailed('$e'));
    }
  }

  Future<void> _showError(String message) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _share(File file) async {
    final share = widget.shareFile;
    if (share != null) {
      await share(file);
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/zip')],
        subject: AppLocalizations.of(context).exportNotes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.dataSection),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Column(
            children: [
              _tile(
                icon: Icons.archive_outlined,
                title: l10n.exportNotes,
                subtitle: _exporting
                    ? l10n.exportInProgress
                    : l10n.exportNotesSubtitle,
                busy: _exporting,
                onTap: _exporting ? null : _export,
              ),
              Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              _tile(
                icon: Icons.upload_file_outlined,
                title: l10n.importNotes,
                subtitle: _importing
                    ? l10n.importInProgress
                    : l10n.importNotesSubtitle,
                busy: _importing,
                onTap: _importing
                    ? null
                    : () => _import(widget.pickFiles ?? _defaultPickFiles),
              ),
              Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              _tile(
                icon: Icons.folder_open_outlined,
                title: l10n.importFolder,
                subtitle: _importing
                    ? l10n.importInProgress
                    : l10n.importFolderSubtitle,
                busy: _importing,
                onTap: _importing
                    ? null
                    : () => _import(widget.pickFolder ?? _defaultPickFolder),
              ),
              if (_exporting)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: LinearProgressIndicator(
                    value: _progress == null || _progress!.total == 0
                        ? null
                        : _progress!.fraction,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool busy,
    required VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
