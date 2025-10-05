import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/routes/app_routes.dart';
import 'presentation/bloc/app_bloc.dart';
import 'presentation/pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (state is AppNavigationRequested) {
          context.pushNamed(
            RouteNames.movieDetail,
            queryParameters: {
              NavArgs.movieId: state.movieId.toString(),
            },
          );
        }
      },
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state is AppInitial) {
            context.read<AppBloc>().add(InitializeApp());
          }

          return HomePage();
        },
      ),
    );
  }
}
