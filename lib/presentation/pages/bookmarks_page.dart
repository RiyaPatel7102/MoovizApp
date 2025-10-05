import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/extensions/sized_box_extension.dart';
import 'package:movie_app/core/utils/sizer_utils.dart';
import 'package:movie_app/presentation/widgets/movie_card.dart';
import 'package:movie_app/theme/custom_text_styles.dart';
import '../bloc/bookmark_bloc.dart';
import '../../core/routes/app_routes.dart';
import '../../theme/theme_helper.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookmarkBloc>().add(LoadBookmarkedMovies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _renderAppBar(),
      body: BlocBuilder<BookmarkBloc, BookmarkState>(
        builder: (context, state) {
          if (state is BookmarkLoading) {
            return _renderLoadingState();
          } else if (state is BookmarkError) {
            return _renderErrorState(state.message);
          } else if (state is BookmarkLoaded) {
            return _renderBookmarksList(state);
          }
          return _renderInitialState();
        },
      ),
    );
  }

  PreferredSizeWidget _renderAppBar() {
    return AppBar(
      title: Text(
        'Bookmarked Movies',
        style: CustomTextStyles.onDarkBold20,
      ),
      backgroundColor: appTheme.black,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: appTheme.onDarkRegular),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _renderLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _renderErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.h,
            color: appTheme.error,
          ),
          16.hSpace,
          Text(
            'Oops! Something went wrong',
            style: CustomTextStyles.onDarkRegular16,
            textAlign: TextAlign.center,
          ),
          16.hSpace,
          ElevatedButton(
            onPressed: () {
              context.read<BookmarkBloc>().add(LoadBookmarkedMovies());
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _renderInitialState() {
    return const Center(
      child: Text('No bookmarked movies yet'),
    );
  }

  Widget _renderBookmarksList(BookmarkLoaded state) {
    if (state.bookmarkedMovies.isEmpty) {
      return _renderEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BookmarkBloc>().add(LoadBookmarkedMovies());
      },
      child: GridView.builder(
        padding: EdgeInsets.all(16.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55.h,
          crossAxisSpacing: 16.h,
          mainAxisSpacing: 16.h,
        ),
        itemCount: state.bookmarkedMovies.length,
        itemBuilder: (context, index) {
          final movie = state.bookmarkedMovies[index];

          return MovieCard(
              movie: movie,
              isBookmarked: true,
              onTap: () => _navigateToMovieDetails(movie.id),
              onBookmarkTap: () => _removeBookmark(movie.id));
        },
      ),
    );
  }

  Widget _renderEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80.h,
            color: appTheme.greyInactive,
          ),
          16.hSpace,
          Text(
            'No Bookmarked Movies',
            style: CustomTextStyles.onDarkBold20,
          ),
          8.hSpace,
          Text(
            'Start bookmarking movies to see them here',
            style: CustomTextStyles.onDarkRegular16,
            textAlign: TextAlign.center,
          ),
          24.hSpace,
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.primary,
              foregroundColor: appTheme.onPrimaryRegular,
            ),
            child: Text('Explore Movies'),
          ),
        ],
      ),
    );
  }

  void _navigateToMovieDetails(int movieId) {
    context.pushNamed(
      RouteNames.movieDetail,
      queryParameters: {
        NavArgs.movieId: movieId.toString(),
      },
    );
  }

  void _removeBookmark(int movieId) {
    context.read<BookmarkBloc>().add(RemoveBookmark(movieId));
  }
}
