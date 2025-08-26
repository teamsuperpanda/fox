import 'dart:io' show Platform;

bool get isInTest => Platform.environment['FLUTTER_TEST'] == 'true';
