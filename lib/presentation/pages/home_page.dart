import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/bookmark_bloc.dart';
import '../widgets/movie_card.dart';
import '../../core/routes/app_routes.dart';
import '../../theme/theme_helper.dart';
import '../../theme/custom_text_styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<MovieBloc>().add(LoadTrendingMovies());
    context.read<BookmarkBloc>().add(LoadBookmarkedMovies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _renderAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<MovieBloc>().add(RefreshMovies());
        },
        child: BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            if (state is MovieLoading) {
              return _renderLoadingState();
            } else if (state is MovieError) {
              return _renderErrorState(state.message);
            } else if (state is MovieLoaded) {
              return _renderLoadedState(state);
            }
            return _renderInitialState();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _renderAppBar() {
    return AppBar(
      title: Text(
        'Mooviz',
        style: CustomTextStyles.onDarkBold24,
      ),
      backgroundColor: appTheme.black,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: appTheme.onDarkRegular),
          onPressed: () {
            context.pushNamed(RouteNames.search);
          },
        ),
        IconButton(
          icon: Icon(Icons.bookmark, color: appTheme.onDarkRegular),
          onPressed: () {
            context.pushNamed(RouteNames.bookmarks);
          },
        ),
      ],
    );
  }

  Widget _renderLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(appTheme.primary),
      ),
    );
  }

  Widget _renderErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: appTheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            style: CustomTextStyles.onDarkRegular16,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<MovieBloc>().add(LoadTrendingMovies());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.primary,
              foregroundColor: appTheme.onPrimaryRegular,
            ),
            child: Text('Retry', style: CustomTextStyles.onPrimaryRegular16),
          ),
        ],
      ),
    );
  }

  Widget _renderInitialState() {
    return const Center(
      child: Text('Welcome to Mooviz'),
    );
  }

  Widget _renderLoadedState(MovieLoaded state) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _renderTrendingSection(state.trendingMovies),
          const SizedBox(height: 24),
          _renderNowPlayingSection(state.nowPlayingMovies),
        ],
      ),
    );
  }

  Widget _renderTrendingSection(List<dynamic> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Trending Movies',
            style: CustomTextStyles.onDarkBold20,
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return BlocBuilder<BookmarkBloc, BookmarkState>(
                builder: (context, bookmarkState) {
                  bool isBookmarked = false;
                  if (bookmarkState is BookmarkLoaded) {
                    isBookmarked =
                        bookmarkState.bookmarkStatus[movie.id] ?? false;
                  }

                  return MovieCard(
                    movie: movie,
                    isBookmarked: isBookmarked,
                    onTap: () => _navigateToMovieDetails(movie.id),
                    onBookmarkTap: () => _toggleBookmark(movie),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _renderNowPlayingSection(List<dynamic> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Now Playing',
            style: CustomTextStyles.onDarkBold20,
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return BlocBuilder<BookmarkBloc, BookmarkState>(
                builder: (context, bookmarkState) {
                  bool isBookmarked = false;
                  if (bookmarkState is BookmarkLoaded) {
                    isBookmarked =
                        bookmarkState.bookmarkStatus[movie.id] ?? false;
                  }

                  return MovieCard(
                    movie: movie,
                    isBookmarked: isBookmarked,
                    onTap: () => _navigateToMovieDetails(movie.id),
                    onBookmarkTap: () => _toggleBookmark(movie),
                  );
                },
              );
            },
          ),
        ),
      ],
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

  void _toggleBookmark(dynamic movie) {
    context.read<BookmarkBloc>().add(ToggleBookmark(movie));
  }
}
