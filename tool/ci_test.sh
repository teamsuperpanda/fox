#!/usr/bin/env bash
set -e
flutter test $(find test/ -name '*_test.dart' ! -name 'screenshot*')
