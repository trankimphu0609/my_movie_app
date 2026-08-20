import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_route.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/favorite_repository.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  List<Movie> _favoriteMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final list = await _favoriteRepository.getFavorites();
    if (mounted) {
      setState(() {
        _favoriteMovies = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy Theme động từ context
    final theme = Theme.of(context);

    return Scaffold(
      // Bỏ backgroundColor cố định
      appBar: AppBar(
        // Bỏ backgroundColor cố định
        title: const Text('Phim Yêu Thích'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      )
          : _favoriteMovies.isEmpty
          ? Center(
        child: Text(
          'Chưa có phim nào trong danh sách yêu thích!',
          style: TextStyle(color: theme.hintColor),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _favoriteMovies.length,
        itemBuilder: (context, index) {
          final movie = _favoriteMovies[index];
          return Card(
            color: theme.cardColor, // Dùng màu card động theo Theme
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: movie.fullPosterPath,
                  width: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 50,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[900]
                        : Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error, color: Colors.red),
                ),
              ),
              title: Text(
                movie.title,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color, // Màu chữ dynamic
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '⭐ ${movie.voteAverage.toStringAsFixed(1)} / 10',
                style: TextStyle(color: theme.hintColor),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: theme.hintColor,
                size: 16,
              ),
              onTap: () async {
                // Mở DetailScreen, sau khi quay lại thì reload lại danh sách
                await Navigator.pushNamed(
                  context,
                  AppRoutes.detail,
                  arguments: movie,
                );
                _loadFavorites();
              },
            ),
          );
        },
      ),
    );
  }
}