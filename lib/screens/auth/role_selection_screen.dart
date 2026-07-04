import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/app_state.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _loading = false;

  Future<void> _choose(UserRole role) async {
    final auth = context.read<AuthService>();
    final appState = context.read<AppState>();
    setState(() => _loading = true);
    await auth.setUserRole(role);
    if (!mounted) return;
    await appState.refresh();
    // RootRouter will now route based on the updated profile automatically.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome to GemNet',
                  style: TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('How will you use the app?',
                  style: TextStyle(color: AppColors.midGrey, fontSize: 15)),
              const SizedBox(height: 32),
              _RoleCard(
                icon: Icons.shopping_bag_outlined,
                title: 'I\'m a Buyer',
                subtitle: 'Browse gems, chat with sellers, verify certificates',
                onTap: _loading ? null : () => _choose(UserRole.buyer),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.storefront_outlined,
                title: 'I\'m a Seller',
                subtitle: 'List gems with AI-assisted details, manage stock, chat with buyers',
                onTap: _loading ? null : () => _choose(UserRole.seller),
              ),
              if (_loading) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator(color: AppColors.white)),
              ],
              const SizedBox(height: 20),
              const Text(
                'Note: Admin accounts are assigned manually by GemNet staff.',
                style: TextStyle(color: AppColors.midGrey, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.richBlack,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkGrey),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.white, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.midGrey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.midGrey),
          ],
        ),
      ),
    );
  }
}
