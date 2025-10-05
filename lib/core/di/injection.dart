import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/services/api_service.dart';
import '../../data/database/database_helper.dart';
import '../../data/repositories/movie_repository.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // External dependencies
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);

    // Add interceptors for better error handling
    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => print('DIO: $obj'),
    ));

    // Add retry interceptor for connection issues
    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          print('Connection error, retrying...');
          // Retry once after a short delay
          Future.delayed(const Duration(seconds: 2), () async {
            try {
              final response = await dio.fetch(error.requestOptions);
              handler.resolve(response);
            } catch (retryError) {
              // handler.next(retryError);
            }
          });
        } else {
          handler.next(error);
        }
      },
    ));

    return dio;
  });

  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // Database
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // API Service
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));

  // Repository
  getIt.registerLazySingleton<MovieRepository>(() => MovieRepository(
        apiService: getIt<ApiService>(),
        databaseHelper: getIt<DatabaseHelper>(),
        connectivity: getIt<Connectivity>(),
      ));
}
