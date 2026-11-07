import 'package:flutter_test/flutter_test.dart';

import '../tool/dcl_ratchet.dart';

void main() {
  group('dart_code_linter ratchet', () {
    test('no regressions when counts match the baseline', () {
      final baseline = {
        'lib/a.dart|issue:no-empty-block': 2,
        'lib/a.dart|metric:maintainability-index': 1,
      };
      expect(regressionsBetween(baseline, Map.of(baseline)), isEmpty);
    });

    test('a higher count is a regression', () {
      final baseline = {'lib/a.dart|issue:no-empty-block': 2};
      final current = {'lib/a.dart|issue:no-empty-block': 3};
      expect(regressionsBetween(baseline, current), [
        'lib/a.dart|issue:no-empty-block: 3 (baseline 2)',
      ]);
    });

    test('a new key is a regression', () {
      final baseline = <String, int>{};
      final current = {'lib/new.dart|issue:avoid-non-null-assertion': 1};
      expect(regressionsBetween(baseline, current), [
        'lib/new.dart|issue:avoid-non-null-assertion: 1 (baseline 0)',
      ]);
    });

    test('a lower count is reported as fixed, not a regression', () {
      final baseline = {'lib/a.dart|issue:no-empty-block': 3};
      final current = {'lib/a.dart|issue:no-empty-block': 1};
      expect(regressionsBetween(baseline, current), isEmpty);
      expect(fixedBetween(baseline, current), [
        'lib/a.dart|issue:no-empty-block: 1 (was 3)',
      ]);
    });

    test('summarize counts rules and metric violations per file', () {
      final report = {
        'records': [
          {
            'path': 'lib/a.dart',
            'issues': [
              {'ruleId': 'no-empty-block'},
              {'ruleId': 'no-empty-block'},
            ],
            'fileMetrics': [
              {'metricsId': 'technical-debt', 'level': 'none'},
            ],
            'classes': {
              'A': {
                'metrics': [
                  {'metricsId': 'number-of-methods', 'level': 'warning'},
                ],
              },
            },
            'functions': {
              'A.build': {
                'metrics': [
                  {'metricsId': 'cyclomatic-complexity', 'level': 'warning'},
                  {'metricsId': 'maintainability-index', 'level': 'none'},
                ],
              },
            },
          },
        ],
      };

      expect(summarize(report), {
        'lib/a.dart|issue:no-empty-block': 2,
        'lib/a.dart|metric:number-of-methods': 1,
        'lib/a.dart|metric:cyclomatic-complexity': 1,
      });
    });
  });
}
