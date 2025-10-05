import 'dart:async';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _linkSubscription;
  final StreamController<int> _movieIdController =
      StreamController<int>.broadcast();

  Stream<int> get movieIdStream => _movieIdController.stream;

  void initialize() {
    _initAppLinks();
  }

  void _initAppLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleIncomingLink(uri.toString());
        }
      },
      onError: (err) {
        print('Error handling deep link: $err');
      },
    );
    _getInitialLink();
  }

  Future<void> _getInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleIncomingLink(uri.toString());
      }
    } catch (e) {
      print('Error getting initial link: $e');
    }
  }

  void _handleIncomingLink(String link) {
    try {
      final uri = Uri.parse(link);
      bool isValidLink = false;
      int? movieId;
      if (uri.scheme == 'https' &&
          uri.host == 'moovizapp' &&
          uri.path.startsWith('/movie/')) {
        isValidLink = true;
        final pathSegments = uri.path.split('/');
        if (pathSegments.length >= 3) {
          movieId = int.tryParse(pathSegments[2]);
        }
      } else if (uri.scheme == 'moovizapp' && uri.host == 'movie') {
        isValidLink = true;
        if (uri.pathSegments.isNotEmpty) {
          movieId = int.tryParse(uri.pathSegments.first);
        } else if (uri.path.isNotEmpty) {
          final pathWithoutSlash = uri.path.replaceFirst('/', '');
          movieId = int.tryParse(pathWithoutSlash);
        }
      }

      if (isValidLink && movieId != null) {
        print('Extracted movie ID: $movieId');
        _movieIdController.add(movieId);
      } else {}
    } catch (e) {
      print('Error parsing deep link: $e');
    }
  }

  String generateMovieDeepLink(int movieId) {
    return 'https://moovizapp/movie/$movieId';
  }

  void dispose() {
    _linkSubscription?.cancel();
    _movieIdController.close();
  }
}
