import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  static const _maxDiffRate = 0.001;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (result.passed || result.diffPercent <= _maxDiffRate) {
      result.dispose();
      return true;
    }

    final String error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

Future<void> testExecutable(Future<void> Function() testRunner) async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
  final fontDir = '$flutterRoot/bin/cache/artifacts/material_fonts';

  final materialIcons =
      await File('$fontDir/MaterialIcons-Regular.otf').readAsBytes();
  final iconLoader = FontLoader('MaterialIcons');
  iconLoader.addFont(Future<ByteData>.value(materialIcons.buffer.asByteData()));
  await iconLoader.load();

  final robotoRegular = await File('$fontDir/Roboto-Regular.ttf').readAsBytes();
  final robotoMedium = await File('$fontDir/Roboto-Medium.ttf').readAsBytes();
  final robotoBold = await File('$fontDir/Roboto-Bold.ttf').readAsBytes();
  final robotoItalic = await File('$fontDir/Roboto-Italic.ttf').readAsBytes();

  final robotoLoader = FontLoader('Roboto');
  robotoLoader
      .addFont(Future<ByteData>.value(robotoRegular.buffer.asByteData()));
  robotoLoader
      .addFont(Future<ByteData>.value(robotoMedium.buffer.asByteData()));
  robotoLoader.addFont(Future<ByteData>.value(robotoBold.buffer.asByteData()));
  robotoLoader
      .addFont(Future<ByteData>.value(robotoItalic.buffer.asByteData()));
  await robotoLoader.load();

  final notoDirs = [
    '/usr/share/fonts/truetype/noto',
    '/usr/share/fonts/opentype/noto',
    '/usr/share/fonts/google-noto',
    '/usr/share/fonts/google-noto-vf',
    '/usr/share/fonts/google-noto-sans-cjk-fonts',
  ];

  Future<void> loadNotoFont(String name, List<String> candidates) async {
    for (final dir in notoDirs) {
      for (final file in candidates) {
        final path = '$dir/$file';
        if (File(path).existsSync()) {
          final bytes = await File(path).readAsBytes();
          final loader = FontLoader(name);
          loader.addFont(Future<ByteData>.value(bytes.buffer.asByteData()));
          await loader.load();
          return;
        }
      }
    }
  }

  await loadNotoFont('NotoNaskhArabic', [
    'NotoSansArabic-Regular.ttf',
    'NotoNaskhArabic-Regular.ttf',
    'NotoNaskhArabic[wght].ttf',
  ]);

  await loadNotoFont('NotoSansDevanagari', [
    'NotoSansDevanagari-Regular.ttf',
    'NotoSansDevanagari[wght].ttf',
  ]);

  await loadNotoFont('NotoSansCJK', [
    'NotoSansCJK-Regular.ttc',
    'NotoSansSC-Regular.otf',
    'NotoSansSC-Regular.ttf',
  ]);

  goldenFileComparator = _TolerantComparator(
    Uri.file('${Directory.current.path}/test/golden_test.dart'),
  );

  await testRunner();
}
