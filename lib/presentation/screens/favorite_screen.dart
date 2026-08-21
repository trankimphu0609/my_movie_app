import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_movie_app/core/language_controller.dart';
import '../../core/app_route.dart';
import '../../core/app_strings.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/favorite_repository.dart';

final GlobalKey<FavoriteScreenState> favoriteScreenKey = GlobalKey<FavoriteScreenState>();
class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {

  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  final ScrollController _scrollController = ScrollController();

  List<Movie> _favoriteMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
    LanguageController.instance.addListener(_onLanguageChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadFavorites();
  }

  @override
  void dispose() {
    LanguageController.instance.addListener(_onLanguageChanged);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadFavorites() async {
    final list = await _favoriteRepository.getFavorites();
    if (mounted) {
      setState(() {
        _favoriteMovies = list;
        _isLoading = false;
      });
    }
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = LanguageController.instance.locale.languageCode;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // AppBar tự động ẩn/hiện khi cuộn
          SliverAppBar(
            title: Text(AppStrings.get('favorite', langCode), style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            floating: true,
            snap: true,
            pinned: false,
          ),

          // Nội dung hiển thị bên dưới
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              ),
            )
          else if (_favoriteMovies.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  AppStrings.get('no_favorites', langCode),
                  style: TextStyle(color: theme.hintColor, fontSize: 15),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  // Thêm padding bọc ngoài để tạo khoảng trống dưới đáy tránh bị BottomBar che
                  final isLast = index == _favoriteMovies.length - 1;
                  final movie = _favoriteMovies[index];

                  return Padding(
                    padding: EdgeInsets.fromLTRB(12, 8, 12, isLast ? 100 : 8),
                    child: Card(
                      color: theme.cardColor,
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
                            color: theme.textTheme.bodyLarge?.color,
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
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.detail,
                            arguments: movie,
                          );
                          loadFavorites();
                        },
                      ),
                    ),
                  );
                },
                childCount: _favoriteMovies.length,
              ),
            ),
        ],
      ),
    );
  }
}