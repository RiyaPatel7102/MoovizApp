import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/utils/sizer_utils.dart';
import 'package:movie_app/theme/theme_helper.dart';
import '../bloc/splash_bloc.dart';
import '../../core/routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<SplashBloc>().add(SplashStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashLoaded) {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: appTheme.backgroundDark,
        body: Center(
          child: _renderLottieAnimation(),
        ),
      ),
    );
  }

  Widget _renderLottieAnimation() {
    return SizedBox(
      width: 200.h,
      height: 200.h,
      child: Lottie.asset(
        'assets/lottie/splash_animation.json',
        fit: BoxFit.contain,
      ),
    );
  }
}
