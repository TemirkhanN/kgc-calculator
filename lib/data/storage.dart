import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PersistentStorage {
  final String _resourceName;
  late final SharedPreferences _storage;
  static SharedPreferences? _globalAdapter;

  static Future<void> bootAsyncShit() async {
    // TODO wtf, flutter. Why there is no normal way to load this cursed thing? FutureBuilder is even worse!
    if (_globalAdapter == null) {
      _globalAdapter = await SharedPreferences.getInstance();
    }
  }

  PersistentStorage(this._resourceName) {
    _storage = _globalAdapter!;
  }

  void save(String key, String value) {
    var data = _fetchAll();
    data[key] = value;
    _storage.setString(_resourceName, jsonEncode(data));
  }

  String? get(String key) {
    var data = _fetchAll();
    if (!data.containsKey(key)) {
      return null;
    }

    return data[key];
  }

  Map<String, dynamic> getAll() {
    return _fetchAll();
  }

  Map<String, dynamic> _fetchAll() {
    return jsonDecode(_storage.getString(_resourceName) ?? '{}');
  }
}
