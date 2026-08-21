import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_movie_app/core/language_controller.dart';
import '../../core/app_route.dart';
import '../../core/app_strings.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MovieRepository _movieRepository = MovieRepository();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Movie> _movies = [];
  List<Map<String, dynamic>> _genres = [];
  int? _selectedGenreId;

  int _currentPage = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isLoadingGenres = true;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadGenres();
    _loadMovies();
    _scrollController.addListener(_onScroll);
    LanguageController.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageController.instance.removeListener(_onLanguageChanged);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isLoading) {
      _loadMoreMovies();
    }
  }

  void _onLanguageChanged() {
    if (mounted) {
      _loadGenres();
      _loadMovies();
    }
  }

  Future<void> _loadGenres() async {
    try {
      final genres = await _movieRepository.getGenres();
      if (mounted) {
        setState(() {
          _genres = genres;
          _isLoadingGenres = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingGenres = false);
    }
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      List<Movie> movies;
      if (_searchController.text.trim().isNotEmpty) {
        movies = await _movieRepository.searchMovies(_searchController.text.trim());
      } else if (_selectedGenreId != null) {
        movies = await _movieRepository.getMoviesByGenre(_selectedGenreId!, page: _currentPage);
      } else {
        movies = await _movieRepository.getPopularMovies(page: _currentPage);
      }

      if (mounted) {
        setState(() {
          _movies = movies;
          _isLoading = false;
          if (movies.length < 20) _hasMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreMovies() async {
    if (_searchController.text.trim().isNotEmpty) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      List<Movie> newMovies;
      if (_selectedGenreId != null) {
        newMovies = await _movieRepository.getMoviesByGenre(_selectedGenreId!, page: _currentPage);
      } else {
        newMovies = await _movieRepository.getPopularMovies(page: _currentPage);
      }

      if (mounted) {
        setState(() {
          if (newMovies.isEmpty) {
            _hasMore = false;
          } else {
            _movies.addAll(newMovies);
          }
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onGenreSelected(int? genreId) {
    if (_selectedGenreId == genreId) return;
    setState(() {
      _selectedGenreId = genreId;
      _searchController.clear();
    });
    _loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final langCode = LanguageController.instance.locale.languageCode;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // AppBar và Thanh tìm kiếm trượt ẩn/hiện
          SliverAppBar(
            title: Text(AppStrings.get('trending', langCode), style: const TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            floating: true,
            snap: true,
            pinned: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.get('search_hint', langCode),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _selectedGenreId = null);
                                            _loadMovies();
                                          },
                              ) : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                  onChanged: (value) {
                    if (value.trim().isNotEmpty) {
                      setState(() => _selectedGenreId = null);
                    }
                    _loadMovies();
                  },
                  onSubmitted: (_) {
                    setState(() => _selectedGenreId = null);
                    _loadMovies();
                  },
                ),
              ),
            ),
          ),

          // Thanh Thể loại Chips
          if (!_isLoadingGenres && _genres.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                height: 48,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _genres.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = _selectedGenreId == null;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(AppStrings.get('all', langCode)),
                          selected: isSelected,
                          selectedColor: Colors.redAccent,
                          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200],
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) => _onGenreSelected(null),
                        ),
                      );
                    }

                    final genre = _genres[index - 1];
                    final isSelected = _selectedGenreId == genre['id'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(genre['name']),
                        selected: isSelected,
                        selectedColor: Colors.redAccent,
                        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200],
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) => _onGenreSelected(genre['id']),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Nội dung lưới hiển thị phim (SliverGrid)
          _isLoading
              ? const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
          )
              : _movies.isEmpty
              ? SliverFillRemaining(
            child: Center(child: Text(AppStrings.get('no_movies', langCode), style: TextStyle(color: theme.hintColor))),
          )
              : SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final movie = _movies[index];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.detail, arguments: movie),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl: movie.fullPosterPath,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: isDarkMode ? Colors.grey[900] : Colors.grey[300],
                              ),
                              errorWidget: (context, url, error) => const Center(
                                child: Icon(Icons.broken_image, size: 40),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      movie.voteAverage.toStringAsFixed(1),
                                      style: TextStyle(fontSize: 12, color: theme.hintColor),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _movies.length,
              ),
            ),
          ),

          // Vòng quay tải thêm trang dưới cùng
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.redAccent),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}