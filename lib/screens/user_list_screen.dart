import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../viewmodels/user_list_viewmodel.dart';
import '../models/user_model.dart';
import 'user_detail_screen.dart';
import 'favorites_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserListViewModel _viewModel = UserListViewModel();
  bool _isOffline = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final bool offline = results.contains(ConnectivityResult.none);
      if (offline != _isOffline) {
        setState(() {
          _isOffline = offline;
        });
        if (!offline) _viewModel.loadUsers();
      }
    });
    _viewModel.loadUsers();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = results.contains(ConnectivityResult.none);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Ver Favoritos',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
              _viewModel.loadUsers(); // Refresh to sync favorites
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isOffline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade800,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text(
                'Sin conexión a Internet',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, child) {
                switch (_viewModel.state) {
                  case ViewState.loading:
                    return const Center(child: CircularProgressIndicator());
                  case ViewState.error:
                    return _buildErrorWidget(_viewModel.errorMessage);
                  case ViewState.success:
                    if (_viewModel.users.isEmpty) {
                      return const Center(child: Text('No hay usuarios disponibles.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () => _viewModel.loadUsers(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _viewModel.users.length,
                        itemBuilder: (context, index) {
                          final user = _viewModel.users[index];
                          return _buildUserCard(user);
                        },
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Ocurrió un error', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _viewModel.loadUsers(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserDetailScreen(user: user)),
          );
          _viewModel.loadUsers();
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Text(user.name[0], style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _iconText(Icons.email_outlined, user.email),
            const SizedBox(height: 4),
            _iconText(Icons.business, user.company.name),
          ],
        ),
        trailing: IconButton(
          icon: Icon(user.isFavorite ? Icons.favorite : Icons.favorite_border, color: user.isFavorite ? Colors.red : Colors.grey),
          onPressed: () => _viewModel.toggleFavorite(user),
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 5),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
