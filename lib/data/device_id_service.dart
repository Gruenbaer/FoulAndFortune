import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  DeviceIdService._();

  static final DeviceIdService instance = DeviceIdService._();
  static const String _key = 'device_id';

  String? _cached;

  Future<String> getDeviceId() async {
    if (_cached != null) {
      return _cached!;
    }

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      _cached = existing;
      return existing;
    }

    final newId = const Uuid().v4();
    await prefs.setString(_key, newId);
    _cached = newId;
    return newId;
  }
}
