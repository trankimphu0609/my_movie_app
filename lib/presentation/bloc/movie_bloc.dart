import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_movie_app/data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';
import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository movieRepository;

  int _currentPage = 1;
  bool _isFetchingMore = false;
  List<Movie> _currentMovies = [];

  MovieBloc({required this.movieRepository}) : super(MovieInitial()) {
    on<FetchPopularMovies>(_onFetchPopularMovies);
    on<LoadMorePopularMovies>(_oLoadMorePopularMovies);
    on<SearchMoviesEvent>(_onSearchMovies);
  }

  // Lấy danh sách phim
  Future<void> _onFetchPopularMovies(FetchPopularMovies event, Emitter<MovieState> emit) async {
    _currentPage = 1;
    _currentMovies.clear();
    emit(MovieLoading());
    try {
      final movies = await movieRepository.getPopularMovies(page: _currentPage);
      _currentMovies = movies;
      emit(MovieLoaded(movies));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  // Phân trang
  Future<void> _oLoadMorePopularMovies(LoadMorePopularMovies event, Emitter<MovieState> emit) async {
    // Nếu đang tải dở hoặc chưa có dữ liệu ban đầu thì không gọi tiếp
    if (_isFetchingMore || state is! MovieLoaded) return;

    _isFetchingMore = true;
    _currentPage ++;

    try {
      final newMovies = await movieRepository.getPopularMovies(page: _currentPage);
      _currentMovies.addAll(newMovies); // Cộng dồn phim mới vào danh sách cũ
      emit(MovieLoaded(List.from(_currentMovies))); // Phát ra state mới
    } catch (e) {
      emit(MovieLoaded(List.from(_currentMovies))); // Giữ nguyên danh sách hiện tại nếu trang sau bị lỗi
    } finally {
      _isFetchingMore = false;
    }
  }

  // Tìm kiếm phim
  Future<void> _onSearchMovies(SearchMoviesEvent event, Emitter<MovieState> emit) async {
    // Nếu ô tìm kiếm trống, load lại danh sách phim phổ biến ban đầu
    if (event.query.trim().isEmpty) {
      add(FetchPopularMovies());
      return;
    }

    emit(MovieLoading());
    try {
      final movies = await movieRepository.searchMovies(event.query);
      emit(MovieLoaded(movies));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

}