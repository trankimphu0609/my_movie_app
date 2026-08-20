import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie_model.dart';

class FavoriteRepository {
  static const String _favKey = 'favorite_movies';

  // Lấy danh sách phim yêu thích đã lưu
  Future<List<Movie>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favList = prefs.getStringList(_favKey) ?? [];

    return favList.map((item) {
      final Map<String, dynamic> jsonMap = jsonDecode(item);
      return Movie.fromJson(jsonMap);
    }).toList();
  }

  // Kiểm tra xem phim đã được yêu thích chưa
  Future<bool> isFavorite(int movieId) async {
    final favorites = await getFavorites();
    return favorites.any((movie) => movie.id == movieId);
  }

  // Thêm hoặc Xóa khỏi danh sách yêu thích (Toggle)
  Future<bool> toggleFavorite(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();
    List<Movie> favorites = await getFavorites();

    bool isFav = favorites.any((m) => m.id == movie.id);

    if (isFav) {
      favorites.removeWhere((m) => m.id == movie.id);
    } else {
      favorites.add(movie);
    }

    final List<String> encodedList =
    favorites.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_favKey, encodedList);

    return !isFav; // Trả về trạng thái mới (true: đã thích, false: bỏ thích)
  }
}