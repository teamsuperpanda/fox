import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

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

  await testRunner();
}
