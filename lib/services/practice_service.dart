import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/practice_drill.dart';

class PracticeService {
  static const _progressKey = 'practice_drill_progress_v1';
  static const _preShotKey = 'practice_pre_shot_check_v1';

  Future<Map<String, DrillProgress>> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null || raw.isEmpty) return {};

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return {};

    return decoded.map(
      (key, value) => MapEntry(
        key,
        DrillProgress.fromJson((value as Map).cast<String, dynamic>()),
      ),
    );
  }

  Future<void> saveProgress(Map<String, DrillProgress> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      progress.map((key, value) => MapEntry(key, value.toJson())),
    );
    await prefs.setString(_progressKey, encoded);
  }

  Future<List<bool>> loadPreShotChecks() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_preShotKey);
    if (values == null || values.length != kPreShotChecklist.length) {
      return List<bool>.filled(kPreShotChecklist.length, false);
    }

    return values.map((v) => v == '1').toList(growable: false);
  }

  Future<void> savePreShotChecks(List<bool> checks) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = checks.map((v) => v ? '1' : '0').toList(growable: false);
    await prefs.setStringList(_preShotKey, payload);
  }
}
