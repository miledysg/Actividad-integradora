import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

enum ViewState { loading, success, error }

class UserListViewModel extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  
  List<User> _users = [];
  List<User> get users => _users;
  
  ViewState _state = ViewState.loading;
  ViewState get state => _state;
  
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> loadUsers() async {
    _state = ViewState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _users = await _repository.getUsers();
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(User user) async {
    await _repository.toggleFavorite(user);
    // User object is updated inside repository/service, 
    // but we notify to update UI icons in the list
    notifyListeners();
  }

  void syncFavorites(List<User> favoriteUsers) {
    final favoriteIds = favoriteUsers.map((u) => u.id).toSet();
    for (var user in _users) {
      user.isFavorite = favoriteIds.contains(user.id);
    }
    notifyListeners();
  }
}
