import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/extensions/sized_box_extension.dart';
import 'package:movie_app/core/utils/sizer_utils.dart';
import 'package:movie_app/theme/custom_text_styles.dart';
import '../bloc/search_bloc.dart';
import '../bloc/bookmark_bloc.dart';
import '../widgets/movie_card.dart';
import '../../core/routes/app_routes.dart';
import '../../theme/theme_helper.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<BookmarkBloc>().add(LoadBookmarkedMovies());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _renderAppBar(),
      body: Column(
        children: [
          _renderSearchBar(),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial) {
                  return _renderInitialState();
                } else if (state is SearchLoading) {
                  return _renderLoadingState();
                } else if (state is SearchError) {
                  return _renderErrorState(state.message);
                } else if (state is SearchLoaded) {
                  return _renderSearchResults(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _renderAppBar() {
    return AppBar(
      title: Text(
        'Search Movies',
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

  Widget _renderSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.h),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, child) {
          return TextField(
            style: CustomTextStyles.onDarkRegular16,
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search for movies...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.h),
                borderSide: BorderSide(color: appTheme.grey3),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.h),
                borderSide: BorderSide(color: appTheme.primary),
              ),
              filled: true,
              fillColor: appTheme.grey2,
            ),
            onChanged: (value) {
              context.read<SearchBloc>().add(SearchQueryChanged(value));
            },
          );
        },
      ),
    );
  }

  Widget _renderInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80.h,
            color: appTheme.greyInactive,
          ),
          16.hSpace,
          Text(
            'Search for Movies',
            style: CustomTextStyles.onDarkBold20,
          ),
          8.hSpace,
          Text(
            'Start typing to search for movies instantly',
            style: CustomTextStyles.onDarkRegular16,
            textAlign: TextAlign.center,
          ),
          16.hSpace,
          Text(
            'Results will appear automatically as you type',
            style: CustomTextStyles.onDarkRegular14,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _renderLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(appTheme.error),
          ),
          16.hSpace,
          Text(
            'Searching movies...',
            style: CustomTextStyles.onDarkRegular16,
            textAlign: TextAlign.center,
          ),
          8.hSpace,
          Text(
            'Please wait while we find results',
            style: CustomTextStyles.onDarkRegular14,
            textAlign: TextAlign.center,
          ),
        ],
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
            size: 64.h,
            color: appTheme.error,
          ),
          16.hSpace,
          Text(
            'Error: $message',
            style: CustomTextStyles.onDarkRegular16,
            textAlign: TextAlign.center,
          ),
          16.hSpace,
          ElevatedButton(
            onPressed: () {
              context
                  .read<SearchBloc>()
                  .add(SearchQueryChanged(_searchController.text));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.primary,
              foregroundColor: appTheme.onPrimaryRegular,
            ),
            child: const Text('Retry Search'),
          ),
        ],
      ),
    );
  }

  Widget _renderSearchResults(SearchLoaded state) {
    if (state.movies.isEmpty) {
      return _renderNoResultsState(state.query);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.hSpace,
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6.h,
              crossAxisSpacing: 16.h,
              mainAxisSpacing: 16.h,
            ),
            itemCount: state.movies.length,
            itemBuilder: (context, index) {
              final movie = state.movies[index];
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

  Widget _renderNoResultsState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter,
            size: 80.h,
            color: appTheme.greyInactive,
          ),
          16.hSpace,
          Text(
            'No Results Found',
            style: CustomTextStyles.onDarkBold20,
          ),
          8.hSpace,
          Text(
            'No movies found for "$query"',
            style: CustomTextStyles.onDarkRegular16,
            textAlign: TextAlign.center,
          ),
          16.hSpace,
          Text(
            'Try searching with different keywords',
            style: CustomTextStyles.onDarkRegular16,
            textAlign: TextAlign.center,
          ),
          8.hSpace,
          Text(
            'Results update automatically as you type',
            style: CustomTextStyles.onDarkRegular16,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(SearchCleared());
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
