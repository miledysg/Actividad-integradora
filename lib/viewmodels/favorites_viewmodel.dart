import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class FavoritesViewModel extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  
  List<User> _favorites = [];
  List<User> get favorites => _favorites;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await _repository.getFavoriteUsers();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFavorite(User user) async {
    await _repository.toggleFavorite(user);
    _favorites.removeWhere((u) => u.id == user.id);
    notifyListeners();
  }
}
