import '../models/user_model.dart';
import '../models/post_model.dart';
import '../services/user_service.dart';
import '../services/favorites_service.dart';

class UserRepository {
  final UserService _userService = UserService();
  final FavoritesService _favoritesService = FavoritesService();

  Future<List<User>> getUsers() async {
    final users = await _userService.fetchUsers();
    final favorites = await _favoritesService.getFavorites();
    final favoriteIds = favorites.map((u) => u.id).toSet();

    for (var user in users) {
      user.isFavorite = favoriteIds.contains(user.id);
    }
    return users;
  }

  Future<List<Post>> getPosts(int userId) {
    return _userService.fetchPostsByUser(userId);
  }

  Future<List<User>> getFavoriteUsers() {
    return _favoritesService.getFavorites();
  }

  Future<void> toggleFavorite(User user) {
    return _favoritesService.toggleFavorite(user);
  }

  Future<bool> isFavorite(int userId) {
    return _favoritesService.isFavorite(userId);
  }
}
