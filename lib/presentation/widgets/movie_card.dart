import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_app/core/extensions/expanded_extension.dart';
import 'package:movie_app/core/extensions/sized_box_extension.dart';
import 'package:movie_app/core/utils/sizer_utils.dart';
import '../../data/models/movie_model.dart';
import '../../theme/theme_helper.dart';
import '../../theme/custom_text_styles.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onTap;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.isBookmarked = false,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200.h,
        margin: EdgeInsets.symmetric(horizontal: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _renderMoviePoster(),
            8.hSpace,
            _renderMovieInfo(),
          ],
        ),
      ),
    );
  }

  Widget _renderMoviePoster() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.h),
          child: CachedNetworkImage(
            imageUrl: movie.fullPosterPath,
            width: 200.h,
            height: 200.h,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 150.h,
              height: 200.h,
              decoration: BoxDecoration(
                color: appTheme.grey2,
                borderRadius: BorderRadius.circular(12.h),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(appTheme.primary),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 150.h,
              height: 200.h,
              decoration: BoxDecoration(
                color: appTheme.grey2,
                borderRadius: BorderRadius.circular(12.h),
              ),
              child: Icon(
                Icons.movie,
                size: 50.h,
                color: appTheme.greyInactive,
              ),
            ),
          ),
        ),
        if (onBookmarkTap != null)
          Positioned(
            top: 8.h,
            right: 8.h,
            child: GestureDetector(
              onTap: onBookmarkTap,
              child: Container(
                padding: EdgeInsets.all(4.h),
                decoration: BoxDecoration(
                  color: appTheme.borderGrey,
                  borderRadius: BorderRadius.circular(20.h),
                ),
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color:
                      isBookmarked ? appTheme.primary : appTheme.onDarkRegular,
                  size: 20.h,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _renderMovieInfo() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: CustomTextStyles.onDarkBold14,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        4.hSpace,
        Row(
          children: [
            Icon(
              Icons.star,
              color: appTheme.primary,
              size: 16.h,
            ),
            4.hSpace,
            Text(
              movie.voteAverage.toStringAsFixed(1),
              style: CustomTextStyles.onDarkSecondary12,
            ).expanded,
            4.hSpace,
            Text(
              movie.year,
              style: CustomTextStyles.onDarkSecondary12,
            ),
          ],
        ),
      ],
    );
  }
}
