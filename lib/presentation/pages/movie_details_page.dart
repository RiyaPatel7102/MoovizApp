import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/movie_details_model.dart';
import '../../data/models/movie_model.dart';
import '../bloc/bookmark_bloc.dart';
import '../bloc/movie_details_bloc.dart';
import '../../core/services/deep_link_service.dart';
import '../../theme/theme_helper.dart';
import '../../theme/custom_text_styles.dart';

class MovieDetailsPage extends StatefulWidget {
  final int movieId;

  const MovieDetailsPage({super.key, required this.movieId});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<MovieDetailsBloc>().add(LoadMovieDetails(widget.movieId));
    context.read<BookmarkBloc>().add(CheckBookmarkStatus(widget.movieId));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
          builder: (context, state) {
            if (state is MovieDetailsLoading) {
              return _renderLoadingState();
            } else if (state is MovieDetailsError) {
              return _renderErrorState(state.message);
            } else if (state is MovieDetailsLoaded) {
              return _renderMovieDetails(state.movieDetails);
            }
            return _renderLoadingState();
          },
        ),
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 64,
              color: appTheme.greyInactive,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load movie details',
              style: CustomTextStyles.onDarkBold20,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection and try again.',
              style: CustomTextStyles.onDarkSecondary16,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<MovieDetailsBloc>()
                    .add(RefreshMovieDetails(widget.movieId));
              },
              icon: Icon(Icons.refresh, color: appTheme.onPrimaryRegular),
              label: Text('Retry', style: CustomTextStyles.onPrimaryRegular16),
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.primary,
                foregroundColor: appTheme.onPrimaryRegular,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderMovieDetails(MovieDetailsModel movieDetails) {
    return CustomScrollView(
      slivers: [
        _renderAppBar(movieDetails),
        SliverToBoxAdapter(
          child: _renderMovieContent(movieDetails),
        ),
      ],
    );
  }

  Widget _renderMovieContent(MovieDetailsModel movieDetails) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _renderMovieTitle(movieDetails),
          const SizedBox(height: 16),
          _renderMovieInfo(movieDetails),
          const SizedBox(height: 16),
          _renderMovieOverview(movieDetails),
          const SizedBox(height: 16),
          _renderMovieGenres(movieDetails),
          const SizedBox(height: 16),
          _renderAdditionalDetails(movieDetails),
        ],
      ),
    );
  }

  Widget _renderAppBar(MovieDetailsModel movieDetails) {
    return SliverAppBar(
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: appTheme.onDarkRegular),
        onPressed: () => context.pop(),
      ),
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: movieDetails.fullBackdropPath,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: appTheme.grey2,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(appTheme.primary),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: appTheme.grey2,
                child: Icon(
                  Icons.movie,
                  size: 50,
                  color: appTheme.greyInactive,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    appTheme.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        BlocBuilder<BookmarkBloc, BookmarkState>(
          builder: (context, state) {
            bool isBookmarked = false;
            if (state is BookmarkLoaded) {
              isBookmarked = state.bookmarkStatus[widget.movieId] ?? false;
            }

            return IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? appTheme.primary : appTheme.onDarkRegular,
              ),
              onPressed: () => _toggleBookmark(movieDetails),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.share, color: appTheme.onDarkRegular),
          onPressed: () => _shareMovie(movieDetails),
        ),
      ],
    );
  }

  Widget _renderMovieTitle(MovieDetailsModel movieDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movieDetails.title,
          style: CustomTextStyles.onDarkBold24,
        ),
        if (movieDetails.tagline.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            movieDetails.tagline,
            style: CustomTextStyles.onDarkSecondary16.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _renderMovieInfo(MovieDetailsModel movieDetails) {
    return Row(
      children: [
        _renderRating(movieDetails),
        const SizedBox(width: 16),
        _renderYear(movieDetails),
        const SizedBox(width: 16),
        _renderDuration(movieDetails),
      ],
    );
  }

  Widget _renderRating(MovieDetailsModel movieDetails) {
    return Row(
      children: [
        Icon(Icons.star, color: appTheme.primary, size: 20),
        const SizedBox(width: 4),
        Text(
          movieDetails.voteAverage.toStringAsFixed(1),
          style: CustomTextStyles.onDarkBold16,
        ),
        Text(
          ' (${movieDetails.voteCount})',
          style: CustomTextStyles.onDarkSecondary14,
        ),
      ],
    );
  }

  Widget _renderYear(MovieDetailsModel movieDetails) {
    return Text(
      movieDetails.year,
      style: CustomTextStyles.onDarkMedium16,
    );
  }

  Widget _renderDuration(MovieDetailsModel movieDetails) {
    return Text(
      movieDetails.duration,
      style: CustomTextStyles.onDarkMedium16,
    );
  }

  Widget _renderMovieOverview(MovieDetailsModel movieDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: CustomTextStyles.onDarkBold20,
        ),
        const SizedBox(height: 8),
        Text(
          movieDetails.overview,
          style: CustomTextStyles.onDarkRegular16.copyWith(height: 1.5),
        ),
      ],
    );
  }

  Widget _renderMovieGenres(MovieDetailsModel movieDetails) {
    if (movieDetails.genres.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres',
          style: CustomTextStyles.onDarkBold20,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: movieDetails.genres.map((genre) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: appTheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                genre.name,
                style: CustomTextStyles.onPrimaryRegular14,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _renderAdditionalDetails(MovieDetailsModel movieDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: CustomTextStyles.onDarkBold20,
        ),
        const SizedBox(height: 8),
        _renderDetailRow('Status', movieDetails.status),
        _renderDetailRow(
            'Language', movieDetails.originalLanguage.toUpperCase()),
        if (movieDetails.productionCompanies.isNotEmpty)
          _renderDetailRow(
            'Production',
            movieDetails.productionCompanies.first.name,
          ),
      ],
    );
  }

  Widget _renderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: CustomTextStyles.onDarkMedium14.copyWith(
                color: appTheme.greyInactive,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: CustomTextStyles.onDarkRegular16,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleBookmark(MovieDetailsModel movieDetails) {
    final movie = MovieModel(
      id: movieDetails.id,
      title: movieDetails.title,
      overview: movieDetails.overview,
      posterPath: movieDetails.posterPath,
      backdropPath: movieDetails.backdropPath,
      releaseDate: movieDetails.releaseDate,
      voteAverage: movieDetails.voteAverage,
      voteCount: movieDetails.voteCount,
      isAdult: movieDetails.isAdult,
      originalLanguage: movieDetails.originalLanguage,
      originalTitle: movieDetails.originalTitle,
      popularity: movieDetails.popularity,
      hasVideo: movieDetails.hasVideo,
    );

    context.read<BookmarkBloc>().add(ToggleBookmark(movie));
  }

  void _shareMovie(MovieDetailsModel movieDetails) {
    final deepLink = DeepLinkService().generateMovieDeepLink(movieDetails.id);
    final shareText = 'Check out this movie: ${movieDetails.title}\n'
        'Rating: ${movieDetails.voteAverage}/10\n'
        'Year: ${movieDetails.year}\n'
        'Overview: ${movieDetails.overview}\n\n'
        'Open in MovieApp: $deepLink\n\n'
        'Download MovieApp to discover more great movies!';

    Share.share(shareText);
  }
}
