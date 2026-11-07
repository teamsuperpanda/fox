import 'dart:convert';
import 'dart:io';

/// Ratchets dart_code_linter findings against a checked-in baseline.
///
/// `dart_code_linter` cannot be used as an analyzer plugin on this Dart
/// toolchain (the legacy plugin mechanism loads but emits nothing, and newer
/// analyzer plugin support is not available), so CI runs the metrics CLI and
/// compares the result with `tool/dcl_baseline.json`. A finding count that
/// grows for any file/rule pair fails the build.
///
/// Usage:
///   dart run tool/dcl_ratchet.dart             # check against the baseline
///   dart run tool/dcl_ratchet.dart --update    # rewrite the baseline
Future<void> main(List<String> args) async {
  final update = args.contains('--update');
  final baselinePath =
      _argValue(args, '--baseline') ?? 'tool/dcl_baseline.json';
  final reportPath = _argValue(args, '--report') ??
      '${Directory.systemTemp.path}/dcl_report.json';

  final result = await Process.run('dart', [
    'run',
    'dart_code_linter:metrics',
    'analyze',
    'lib',
    '--reporter',
    'json',
    '--json-path',
    reportPath,
  ]);
  // The metrics command exits non-zero when it reports findings. The report
  // file is the source of truth, so only a missing report is a hard failure.
  if (!File(reportPath).existsSync()) {
    stderr.writeln('dart_code_linter produced no report:');
    stderr.writeln(result.stdout);
    stderr.writeln(result.stderr);
    exit(result.exitCode == 0 ? 1 : result.exitCode);
  }

  final report =
      jsonDecode(File(reportPath).readAsStringSync()) as Map<String, dynamic>;
  final current = summarize(report);

  if (update) {
    File(baselinePath)
      ..createSync(recursive: true)
      ..writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert({
              'total': current.values.fold<int>(0, (sum, count) => sum + count),
              'findings': current,
            })}\n',
      );
    stdout.writeln(
        'Baseline written to $baselinePath (${current.length} entries).');
    return;
  }

  final baselineFile = File(baselinePath);
  if (!baselineFile.existsSync()) {
    stderr.writeln('Missing $baselinePath. Run with --update to create it.');
    exit(1);
  }
  final baseline =
      (jsonDecode(baselineFile.readAsStringSync()) as Map<String, dynamic>)
          .cast<String, dynamic>();

  final baselineFindings =
      (baseline['findings'] as Map<String, dynamic>).cast<String, int>();
  final regressions = regressionsBetween(baselineFindings, current);
  final fixed = fixedBetween(baselineFindings, current);

  stdout.writeln(
    'dart_code_linter: ${current.values.fold<int>(0, (s, c) => s + c)} '
    'findings (baseline ${baselineFindings.values.fold<int>(0, (s, c) => s + c)})',
  );
  for (final entry in fixed) {
    stdout.writeln('  fixed: $entry');
  }
  if (regressions.isEmpty) {
    stdout.writeln('No new findings. Ratchet holds.');
    return;
  }
  stderr.writeln('New dart_code_linter findings:');
  for (final entry in regressions) {
    stderr.writeln('  $entry');
  }
  stderr.writeln(
    'Fix them, or run `dart run tool/dcl_ratchet.dart --update` if the '
    'baseline is intended to grow.',
  );
  exit(1);
}

/// Aggregates findings as `path|issue:<rule>` and `path|metric:<id>` counts.
Map<String, int> summarize(Map<String, dynamic> report) {
  final counts = <String, int>{};
  void bump(String key) => counts[key] = (counts[key] ?? 0) + 1;

  void addMetrics(String path, List<dynamic> metrics) {
    for (final metric in metrics.cast<Map<String, dynamic>>()) {
      final level = metric['level'];
      if (level == 'warning' || level == 'error') {
        bump('$path|metric:${metric['metricsId']}');
      }
    }
  }

  void addClasses(String path, Map<String, dynamic> classes) {
    for (final entry in classes.values) {
      final data = entry as Map<String, dynamic>;
      addMetrics(path, (data['metrics'] as List<dynamic>?) ?? const []);
    }
  }

  for (final record
      in (report['records'] as List<dynamic>).cast<Map<String, dynamic>>()) {
    final path = record['path'] as String;
    for (final issue in (record['issues'] as List<dynamic>?) ?? const []) {
      bump('$path|issue:${(issue as Map<String, dynamic>)['ruleId']}');
    }
    for (final pattern
        in (record['antiPatternCases'] as List<dynamic>?) ?? const []) {
      bump(
          '$path|anti-pattern:${(pattern as Map<String, dynamic>)['patternId']}');
    }
    addMetrics(path, (record['fileMetrics'] as List<dynamic>?) ?? const []);
    addClasses(path, (record['classes'] as Map<String, dynamic>?) ?? const {});
    final functions =
        (record['functions'] as Map<String, dynamic>?) ?? const {};
    for (final function in functions.values) {
      addMetrics(
        path,
        ((function as Map<String, dynamic>)['metrics'] as List<dynamic>?) ??
            const [],
      );
    }
  }
  return counts;
}

/// Keys whose count is higher than the baseline.
List<String> regressionsBetween(
  Map<String, int> baseline,
  Map<String, int> current,
) {
  final result = <String>[];
  for (final entry in current.entries) {
    final allowed = baseline[entry.key] ?? 0;
    if (entry.value > allowed) {
      result.add('${entry.key}: ${entry.value} (baseline $allowed)');
    }
  }
  return result..sort();
}

/// Keys that improved since the baseline, so burn-down is visible.
List<String> fixedBetween(
  Map<String, int> baseline,
  Map<String, int> current,
) {
  final result = <String>[];
  for (final entry in baseline.entries) {
    final count = current[entry.key] ?? 0;
    if (count < entry.value) {
      result.add('${entry.key}: $count (was ${entry.value})');
    }
  }
  return result..sort();
}

String? _argValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index == args.length - 1) return null;
  return args[index + 1];
}
