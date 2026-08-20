import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_route.dart';
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Bắt sự kiện cuộn xuống gần cuối danh sách
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isLoading) {
      _loadMoreMovies();
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

  // Tải danh sách phim trang đầu tiên
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

  // Tải thêm phim khi cuộn xuống đáy (Pagination)
  Future<void> _loadMoreMovies() async {
    // Không phân trang thêm khi đang ở chế độ tìm kiếm
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phim Hot', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm phim...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadMovies();
                  },
                )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: (_) {
                setState(() => _selectedGenreId = null);
                _loadMovies();
              },
            ),
          ),

          // Thanh Thể loại Chips
          if (!_isLoadingGenres && _genres.isNotEmpty)
            SizedBox(
              height: 48,
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
                        label: const Text('Tất cả'),
                        selected: isSelected,
                        selectedColor: Colors.redAccent,
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
          const SizedBox(height: 8),

          // Danh sách phim GridView kết hợp loading dưới đáy
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                : _movies.isEmpty
                ? Center(child: Text('Không tìm thấy phim nào!', style: TextStyle(color: theme.hintColor)))
                : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _movies.length,
                    itemBuilder: (context, index) {
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
                                    color: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[300],
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
                  ),
                ),

                // Hiển thị vòng quay Loading nhỏ ở dưới khi đang cuộn tải trang mới
                if (_isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.redAccent),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}