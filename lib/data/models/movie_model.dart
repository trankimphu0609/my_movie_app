import '../../core/constants.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
  });

  // Factory constructor để parse dữ liệu từ JSON trả về của TMDB
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'],
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
    };
  }

  // Helper getters để lấy full URL đường dẫn ảnh
  String get fullPosterPath {
    if (posterPath != null && posterPath!.isNotEmpty) {
      return '${ApiConstants.baseImageUrl}$posterPath';
    }
    return 'https://via.placeholder.com/500x750?text=No+Image'; // Trả về ảnh placeholder nếu phim không có poster
  }

  String get fullBackdropPath {
    if (backdropPath != null && backdropPath!.isNotEmpty) {
      return '${ApiConstants.baseImageUrl}$backdropPath';
    }
    return 'https://via.placeholder.com/500x281?text=No+Image';
  }
}
