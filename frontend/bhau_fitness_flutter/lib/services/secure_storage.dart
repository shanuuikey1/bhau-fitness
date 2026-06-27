import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  Future<String?> read(String key) async => await _storage.read(key: key);

  Future<void> delete(String key) async => await _storage.delete(key: key);

  Future<void> writeInt(String key, int value) async => await write(key: key, value: value.toString());
  Future<int?> readInt(String key) async {
    final v = await read(key);
    return v != null ? int.tryParse(v) : null;
  }

  Future<void> writeBool(String key, bool value) async => await write(key: key, value: value ? 'true' : 'false');
  Future<bool?> readBool(String key) async {
    final v = await read(key);
    if (v == null) return null;
    return v.toLowerCase() == 'true';
  }

  Future<void> writeStringList(String key, List<String> values) async => await write(key: key, value: values.join('||'));
  Future<List<String>> readStringList(String key) async {
    final v = await read(key);
    if (v == null || v.isEmpty) return [];
    return v.split('||');
  }
}
