import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';

class BannedScreen extends StatelessWidget {
  const BannedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, color: AppColors.error, size: 56),
              const SizedBox(height: 16),
              const Text('Account suspended',
                  style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Your account has been suspended by an administrator. Contact support if you believe this is a mistake.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.midGrey),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => context.read<AppState>().signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
