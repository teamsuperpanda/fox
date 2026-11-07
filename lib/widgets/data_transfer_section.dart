import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/export/export_service.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// "Data" section for the view options sheet: export now, import later.
///
/// Dependencies are injectable so the export flow can be widget tested
/// without platform plugins.
class DataTransferSection extends StatefulWidget {
  const DataTransferSection({
    required this.controller,
    required this.settingsService,
    this.exporter,
    this.outputDirectoryProvider,
    this.shareFile,
    super.key,
  });

  final NotesController controller;
  final SettingsService settingsService;
  final FoxExporter? exporter;
  final Future<Directory> Function()? outputDirectoryProvider;
  final Future<void> Function(File file)? shareFile;

  @override
  State<DataTransferSection> createState() => _DataTransferSectionState();
}

class _DataTransferSectionState extends State<DataTransferSection> {
  bool _exporting = false;
  ExportProgress? _progress;

  Settings get _settingsSnapshot => Settings(
        themeMode: widget.settingsService.getThemeMode().name,
        locale: widget.settingsService.getLocale(),
        showTags: widget.settingsService.getShowTags(),
        showContent: widget.settingsService.getShowContent(),
        alternatingColors: widget.settingsService.getAlternatingColors(),
        fabAnimation: widget.settingsService.getFabAnimation(),
        sortBy: widget.settingsService.getSortBy(),
        accentColor: widget.settingsService.getAccentColor(),
      );

  Future<Directory> _defaultOutputDirectory() async {
    final documents = await getApplicationDocumentsDirectory();
    return Directory('${documents.path}/exports');
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final exporter = widget.exporter ?? FoxExporter();
    final directoryProvider =
        widget.outputDirectoryProvider ?? _defaultOutputDirectory;

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
        settings: _settingsSnapshot,
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
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          content: Text(l10n.exportFailed('$e')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        ),
      );
    }
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
              ListTile(
                leading:
                    Icon(Icons.archive_outlined, color: colorScheme.primary),
                title: Text(l10n.exportNotes),
                subtitle: Text(
                  _exporting ? l10n.exportInProgress : l10n.exportNotesSubtitle,
                ),
                trailing: _exporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _exporting ? null : _export,
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
