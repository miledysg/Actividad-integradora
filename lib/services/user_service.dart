import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/post_model.dart';

class UserService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration _timeout = Duration(seconds: 10);

  Future<List<User>> fetchUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/users'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => User.fromJson(item)).toList();
      } else {
        throw Exception('Servidor respondió con código: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No hay conexión a Internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  Future<List<Post>> fetchPostsByUser(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/posts?userId=$userId'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Post.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar publicaciones (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No hay conexión a Internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al obtener posts: $e');
    }
  }
}
