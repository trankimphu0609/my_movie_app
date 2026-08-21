import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_movie_app/core/language_controller.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/app_route.dart';
import '../../core/app_strings.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/favorite_repository.dart';
import '../../data/repositories/movie_repository.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  final MovieRepository _movieRepository = MovieRepository();

  YoutubePlayerController? _youtubeController;

  final langCode = LanguageController.instance.locale.languageCode;

  List<Movie> _similarMovies = [];
  bool _isFavorite = false;
  bool _isLoadingTrailer = true;
  bool _isLoadingSimilar = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _loadTrailer();
    _loadSimilarMovies();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoriteRepository.isFavorite(widget.movie.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _loadTrailer() async {
    final key = await _movieRepository.getMovieTrailerKey(widget.movie.id);
    if (mounted) {
      if (key != null && key.isNotEmpty) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: key,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            isLive: false,
            forceHD: false,
            enableCaption: true,
          ),
        );
      }
      setState(() {
        _isLoadingTrailer = false;
      });
    }
  }

  Future<void> _loadSimilarMovies() async {
    try {
      final list = await _movieRepository.getSimilarMovies(widget.movie.id);
      if (mounted) {
        setState(() {
          _similarMovies = list;
          _isLoadingSimilar = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingSimilar = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final newStatus = await _favoriteRepository.toggleFavorite(widget.movie);
    if (mounted) {
      setState(() {
        _isFavorite = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? AppStrings.get('added_favorite', langCode)
                : AppStrings.get('removed_favorite', langCode),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = LanguageController.instance.locale.languageCode;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. SliverAppBar tự động ẩn/hiện khi cuộn
          SliverAppBar(
            title: Text(
              widget.movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            floating: true,
            snap: true,
            pinned: false, // 👈 Đặt false để khi kéo lên nó ẩn luôn khỏi màn hình
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : theme.iconTheme.color,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),

          // 2. Nội dung bên dưới chuyển thành SliverToBoxAdapter
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trailer hoặc Backdrop Image
                _isLoadingTrailer
                    ? Container(
                  height: 220,
                  color: theme.brightness == Brightness.dark
                      ? Colors.black
                      : Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  ),
                )
                    : _youtubeController != null
                    ? YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.redAccent,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.red,
                    handleColor: Colors.redAccent,
                  ),
                )
                    : Image.network(
                  widget.movie.fullBackdropPath,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    color: Colors.grey[800],
                    child: const Icon(Icons.movie, size: 50),
                  ),
                ),

                // Thông tin chi tiết phim
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.movie.voteAverage.toStringAsFixed(1)} / 10',
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (widget.movie.releaseDate != null &&
                              widget.movie.releaseDate!.isNotEmpty)
                            Text(
                              '${AppStrings.get('release_date', langCode)}: ${widget.movie.releaseDate}',
                              style: TextStyle(color: theme.hintColor),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.get('overview', langCode),
                        style: TextStyle(
                          color: theme.textTheme.titleLarge?.color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.movie.overview.isNotEmpty
                            ? widget.movie.overview
                            : AppStrings.get('no_overview', langCode),
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.8) ??
                              theme.hintColor,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 32, thickness: 1),

                // Danh sách Phim Tương Tự
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    AppStrings.get('similar_movies', langCode),
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (_isLoadingSimilar)
                  const SizedBox(
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.redAccent),
                    ),
                  )
                else if (_similarMovies.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      AppStrings.get('no_similar', langCode),
                      style: TextStyle(color: theme.hintColor),
                    ),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _similarMovies.length,
                      itemBuilder: (context, index) {
                        final similarMovie = _similarMovies[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.detail,
                              arguments: similarMovie,
                            );
                          },
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: similarMovie.fullPosterPath,
                                      width: 120,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: theme.brightness == Brightness.dark
                                            ? Colors.grey[900]
                                            : Colors.grey[300],
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: Colors.grey[800],
                                            child: const Icon(Icons.broken_image),
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  similarMovie.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      similarMovie.voteAverage.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}