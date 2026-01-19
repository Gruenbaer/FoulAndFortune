import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

LazyDatabase openConnectionImpl() {
  return LazyDatabase(() async {
    final isTest = const bool.fromEnvironment('FLUTTER_TEST') ||
        Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      return NativeDatabase.memory();
    }
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, 'foul_and_fortune.sqlite'));
    return NativeDatabase(file);
  });
}
