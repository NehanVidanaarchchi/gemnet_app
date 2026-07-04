import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _testLogin(UserRole role) async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthService>();
      await auth.signInAsTestUser(role);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.diamond_outlined,
                  color: AppColors.white,
                  size: 64,
                ),

                const SizedBox(height: 16),

                const Text(
                  'GemNet',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Sri Lanka\'s trusted gem marketplace',
                  style: TextStyle(
                    color: AppColors.midGrey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                _LoginButton(
                  label: 'Test Login as Buyer',
                  icon: Icons.shopping_bag_outlined,
                  loading: _loading,
                  onPressed: () => _testLogin(UserRole.buyer),
                ),

                const SizedBox(height: 12),

                _LoginButton(
                  label: 'Test Login as Seller',
                  icon: Icons.storefront_outlined,
                  loading: _loading,
                  onPressed: () => _testLogin(UserRole.seller),
                ),

                const SizedBox(height: 12),

                _LoginButton(
                  label: 'Test Login as Admin',
                  icon: Icons.admin_panel_settings_outlined,
                  loading: _loading,
                  onPressed: () => _testLogin(UserRole.admin),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Testing mode: No Gmail required.',
                  style: TextStyle(
                    color: AppColors.midGrey,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.black,
                ),
              )
            : Icon(icon),
        label: Text(label),
      ),
    );
  }
}