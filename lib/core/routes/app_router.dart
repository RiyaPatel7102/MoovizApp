import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/extensions/sized_box_extension.dart';
import 'package:movie_app/core/utils/sizer_utils.dart';
import 'package:movie_app/theme/custom_text_styles.dart';
import 'package:movie_app/theme/theme_helper.dart';
import 'app_routes.dart';
import '../../presentation/pages/splash_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/search_page.dart';
import '../../presentation/pages/bookmarks_page.dart';
import '../../presentation/pages/movie_details_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.movieDetail,
        name: RouteNames.movieDetail,
        builder: (context, state) {
          final movieId = int.tryParse(
            state.uri.queryParameters[NavArgs.movieId] ?? '',
          );
          return MovieDetailsPage(movieId: movieId ?? 0);
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        name: RouteNames.search,
        builder: (context, state) {
          return const SearchPage();
        },
      ),
      GoRoute(
        path: AppRoutes.bookmarks,
        name: RouteNames.bookmarks,
        builder: (context, state) => const BookmarksPage(),
      ),
      GoRoute(
        path: '${AppRoutes.deepLinkMovie}/:${NavArgs.movieId}',
        name: RouteNames.deepLinkMovie,
        builder: (context, state) {
          final movieId = int.tryParse(
            state.pathParameters[NavArgs.movieId] ?? '',
          );

          if (movieId == null) {
            return const HomePage();
          }

          return MovieDetailsPage(movieId: movieId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.h,
              color: appTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri.toString()}',
              style: CustomTextStyles.onDarkBold20,
              textAlign: TextAlign.center,
            ),
            16.hSpace,
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child:
                  Text('Go Home', style: CustomTextStyles.onPrimaryRegular16),
            ),
          ],
        ),
      ),
    ),
  );
}
