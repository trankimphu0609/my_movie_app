import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_movie_app/core/language_controller.dart';
import 'core/app_route.dart';
import 'core/app_theme.dart';
import 'data/repositories/movie_repository.dart';
import 'logic/cubits/theme_cubit.dart';
import 'presentation/bloc/movie_bloc.dart';
import 'presentation/bloc/movie_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await LanguageController.instance.loadLanguage();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    LanguageController.instance.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
        // Đưa MovieBloc lên đây để không bị reset khi đổi Theme
        BlocProvider(
          create: (context) => MovieBloc(
            movieRepository: MovieRepository(),
          )..add(FetchPopularMovies()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Movie App',
            debugShowCheckedModeBanner: false,
            locale: LanguageController.instance.locale,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            initialRoute: AppRoutes.home,
            routes: AppRoutes.getRoutes(),
          );
        },
      ),
    );
  }
}