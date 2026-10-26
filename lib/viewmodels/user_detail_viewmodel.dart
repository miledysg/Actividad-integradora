import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../repositories/user_repository.dart';

enum PostState { loading, success, error }

class UserDetailViewModel extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  final User user;

  UserDetailViewModel(this.user);

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  PostState _state = PostState.loading;
  PostState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  Future<void> init() async {
    _isFavorite = user.isFavorite;
    await checkFavoriteStatus();
    await loadPosts();
  }

  Future<void> checkFavoriteStatus() async {
    _isFavorite = await _repository.isFavorite(user.id);
    notifyListeners();
  }

  Future<void> loadPosts() async {
    _state = PostState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _posts = await _repository.getPosts(user.id);
      _state = PostState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = PostState.error;
    }
    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    await _repository.toggleFavorite(user);
    _isFavorite = user.isFavorite;
    notifyListeners();
  }
}
