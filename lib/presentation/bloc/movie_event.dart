import 'package:equatable/equatable.dart';

abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object?> get props => [];
}

// Event bắt đầu lấy danh sách phim
class FetchPopularMovies extends MovieEvent {}

// Event tim kiem phim
class SearchMoviesEvent extends MovieEvent {
  final String query;

  const SearchMoviesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

// Event goi them du lieu cho trang tiep theo
class LoadMorePopularMovies extends MovieEvent {}