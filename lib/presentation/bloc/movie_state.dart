import 'package:equatable/equatable.dart';
import '../../data/models/movie_model.dart';

abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object?> get props => [];
}

// Trạng thái ban đầu
class MovieInitial extends MovieState {}

// Trạng thái đang tải dữ liệu (hiện vòng xoay Loading)
class MovieLoading extends MovieState {}

// Trạng thái tải thành công (trả về danh sách phim)
class MovieLoaded extends MovieState {
  final List<Movie> movies;

  const MovieLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

// Trạng thái xảy ra lỗi (hiện thông báo lỗi)
class MovieError extends MovieState {
  final String message;

  const MovieError(this.message);

  @override
  List<Object?> get props => [message];
}