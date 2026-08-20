import 'package:flutter/material.dart';
import '../presentation/screens/main_screen.dart';
import '../presentation/screens/detail_screen.dart';
import '../data/models/movie_model.dart';

class AppRoutes {
  static const String home = '/';
  static const String detail = '/detail';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const MainScreen(),
      detail: (context) {
        final movie = ModalRoute.of(context)!.settings.arguments as Movie;
        return DetailScreen(movie: movie);
      },
    };
  }
}