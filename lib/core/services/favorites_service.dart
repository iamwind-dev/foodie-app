import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'saved_recipes';

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final data = jsonDecode(raw);
      if (data is List) {
        return data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> saveFavorite(Map<String, dynamic> recipe) async {
    final list = await getFavorites();
    final existingIndex = list.indexWhere((e) => (e['title'] ?? '') == (recipe['title'] ?? ''));
    if (existingIndex >= 0) {
      list[existingIndex] = recipe;
    } else {
      list.add(recipe);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list));
  }

  Future<void> removeFavorite(String title) async {
    final list = await getFavorites();
    list.removeWhere((e) => (e['title'] ?? '') == title);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list));
  }
}

