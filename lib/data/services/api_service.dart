import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/movie_response_model.dart';
import '../models/movie_details_model.dart';
import '../../core/constants/api_constants.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET(ApiConstants.trendingMovies)
  Future<MovieResponseModel> getTrendingMovies(
    @Query('api_key') String apiKey,
    @Query('page') int page,
  );

  @GET(ApiConstants.nowPlayingMovies)
  Future<MovieResponseModel> getNowPlayingMovies(
    @Query('api_key') String apiKey,
    @Query('page') int page,
  );

  @GET(ApiConstants.searchMovies)
  Future<MovieResponseModel> searchMovies(
    @Query('api_key') String apiKey,
    @Query('query') String query,
    @Query('include_adult') bool includeAdult,
    @Query('language') String language,
    @Query('page') int page,
  );

  @GET('${ApiConstants.movieDetails}/{id}')
  Future<MovieDetailsModel> getMovieDetails(
    @Path('id') int movieId,
    @Query('api_key') String apiKey,
  );
}
