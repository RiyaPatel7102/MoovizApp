import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../core/services/deep_link_service.dart';
import '../../presentation/bloc/app_bloc.dart';
import '../../presentation/bloc/splash_bloc.dart';
import '../../presentation/bloc/movie_bloc.dart';
import '../../presentation/bloc/search_bloc.dart';
import '../../presentation/bloc/bookmark_bloc.dart';
import '../../presentation/bloc/movie_details_bloc.dart';

class BlocProviders {
  static List<BlocProvider> get providers => [
        BlocProvider<AppBloc>(
          create: (context) => AppBloc(
            deepLinkService: DeepLinkService(),
          ),
        ),
        BlocProvider<SplashBloc>(
          create: (context) => SplashBloc(),
        ),
        BlocProvider<MovieBloc>(
          create: (context) => MovieBloc(
            movieRepository: getIt(),
          ),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(
            movieRepository: getIt(),
          ),
        ),
        BlocProvider<BookmarkBloc>(
          create: (context) => BookmarkBloc(
            movieRepository: getIt(),
          ),
        ),
        BlocProvider<MovieDetailsBloc>(
          create: (context) => MovieDetailsBloc(
            movieRepository: getIt(),
          ),
        ),
      ];
}
