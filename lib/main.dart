import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/utils/sizer_utils.dart';
import 'package:movie_app/theme/theme_helper.dart';
import 'core/di/injection.dart';
import 'core/routes/app_router.dart';
import 'core/providers/bloc_providers.dart';
import 'core/services/deep_link_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  DeepLinkService().initialize();

  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: BlocProviders.providers,
      child: Sizer(
        builder: (context, orientation, deviceType) => MaterialApp.router(
          title: 'Mooviz',
          theme: theme,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
