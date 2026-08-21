import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String baseImageUrl = 'https://image.tmdb.org/t/p/w500';
}