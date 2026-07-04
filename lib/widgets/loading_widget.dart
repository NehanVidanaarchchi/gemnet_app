import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../theme/app_theme.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SpinKitFadingCircle(color: AppColors.white, size: 44),
            const SizedBox(height: 20),
            Text('GemNet', style: TextStyle(color: AppColors.white, fontSize: 18, letterSpacing: 3)),
          ],
        ),
      ),
    );
  }
}

class InlineLoading extends StatelessWidget {
  final String? message;
  const InlineLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SpinKitFadingCircle(color: AppColors.white, size: 32),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: const TextStyle(color: AppColors.lightGrey)),
          ]
        ],
      ),
    );
  }
}
