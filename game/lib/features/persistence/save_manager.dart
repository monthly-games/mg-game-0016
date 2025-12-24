import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/player_data.dart';

class SaveManager {
  static const String _playerDataKey = 'player_data';

  // Singleton pattern for easy access if needed, or better via DI
  static final SaveManager _instance = SaveManager._internal();
  factory SaveManager() => _instance;
  SaveManager._internal();

  Future<void> savePlayerData(PlayerData data) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(data.toJson());
    await prefs.setString(_playerDataKey, jsonString);
  }

  Future<PlayerData?> loadPlayerData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_playerDataKey);

    if (jsonString == null) {
      return null;
    }

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return PlayerData.fromJson(jsonMap);
    } catch (e) {
      // Handle corruption or upgrade issues
      print("Error loading player data: $e");
      return null;
    }
  }

  Future<void> clearSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playerDataKey);
  }
}
