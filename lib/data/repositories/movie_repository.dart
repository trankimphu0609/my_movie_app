import 'package:dio/dio.dart';
import 'package:my_movie_app/core/constants.dart';
import 'package:my_movie_app/data/models/movie_model.dart';

class MovieRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // 1. Lấy danh sách phim phổ biến (có hỗ trợ phân trang & tiếng Việt)
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {
          'api_key': ApiConstants.apiKey,
          'language': 'vi-VN',
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Không thể tải danh sách phim phổ biến');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // 2. Tìm kiếm phim theo từ khóa (có tiếng Việt)
  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {
          'api_key': ApiConstants.apiKey,
          'language': 'vi-VN',
          'query': query,
        },
      );

      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Không thể tìm kiếm phim');
      }
    } catch (e) {
      throw Exception('Lỗi tìm kiếm: $e');
    }
  }

  // 3. Lấy khóa Trailer YouTube
  Future<String?> getMovieTrailerKey(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId/videos',
        queryParameters: {'api_key': ApiConstants.apiKey},
      );

      if (response.statusCode == 200) {
        final List results = response.data['results'] ?? [];
        final trailer = results.firstWhere(
              (video) => video['site'] == 'YouTube' && video['type'] == 'Trailer',
          orElse: () => results.isNotEmpty ? results.first : null,
        );
        return trailer != null ? trailer['key'] as String? : null;
      }
    } catch (_) {}
    return null;
  }

  // 4. Lấy danh sách Thể loại phim
  Future<List<Map<String, dynamic>>> getGenres() async {
    try {
      final response = await _dio.get(
        '/genre/movie/list',
        queryParameters: {
          'api_key': ApiConstants.apiKey,
          'language': 'vi-VN',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['genres']);
      }
    } catch (_) {}
    return [];
  }

  // 5. Lấy danh sách phim theo ID thể loại (có phân trang)
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'api_key': ApiConstants.apiKey,
          'language': 'vi-VN',
          'with_genres': genreId,
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Không thể tải danh sách phim theo thể loại');
      }
    } catch (e) {
      throw Exception('Lỗi tải thể loại: $e');
    }
  }

  // 6. Lấy danh sách Phim tương tự / Gợi ý
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId/similar',
        queryParameters: {
          'api_key': ApiConstants.apiKey,
          'language': 'vi-VN',
          'page': 1,
        },
      );

      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }
}