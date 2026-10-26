import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class FavoritesService {
  static const String _storageKey = 'favorite_users';

  Future<List<User>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_storageKey);
    if (favoritesJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      return decoded.map((item) => User.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> toggleFavorite(User user) async {
    final prefs = await SharedPreferences.getInstance();
    List<User> favorites = await getFavorites();

    final index = favorites.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      favorites.removeAt(index);
      user.isFavorite = false;
    } else {
      user.isFavorite = true;
      favorites.add(user);
    }

    final String encoded = jsonEncode(favorites.map((u) => u.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<bool> isFavorite(int userId) async {
    final favorites = await getFavorites();
    return favorites.any((u) => u.id == userId);
  }
}
