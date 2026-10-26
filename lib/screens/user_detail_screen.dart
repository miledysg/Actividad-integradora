import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../viewmodels/user_detail_viewmodel.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late UserDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = UserDetailViewModel(widget.user);
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.user.name),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  _viewModel.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _viewModel.isFavorite ? Colors.red : null,
                ),
                onPressed: () => _viewModel.toggleFavorite(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoSection(),
                const Divider(height: 30, thickness: 1, indent: 20, endIndent: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Publicaciones',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                _buildPostsSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoTile(Icons.person, 'Username', widget.user.username),
          _infoTile(Icons.email, 'Email', widget.user.email),
          _infoTile(Icons.phone, 'Teléfono', widget.user.phone),
          _infoTile(Icons.language, 'Sitio Web', widget.user.website),
          _infoTile(Icons.location_on, 'Dirección', widget.user.address.toString()),
          _infoTile(Icons.business, 'Empresa', widget.user.company.name),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              '"${widget.user.company.catchPhrase}"\n${widget.user.company.bs}',
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection() {
    switch (_viewModel.state) {
      case PostState.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(),
          ),
        );
      case PostState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text('Error: ${_viewModel.errorMessage}'),
                TextButton.icon(
                  onPressed: () => _viewModel.loadPosts(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        );
      case PostState.success:
        if (_viewModel.posts.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No hay publicaciones disponibles.'),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _viewModel.posts.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final post = _viewModel.posts[index];
            return ListTile(
              title: Text(
                post.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(post.body),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            );
          },
        );
    }
  }
}
