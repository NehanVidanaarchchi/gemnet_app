import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AppState>().currentUserProfile;
    if (profile == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profile', style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.charcoal,
              backgroundImage: profile.photoUrl != null ? NetworkImage(profile.photoUrl!) : null,
              child: profile.photoUrl == null ? const Icon(Icons.person, size: 40, color: AppColors.midGrey) : null,
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(profile.name, style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w600))),
          Center(child: Text(profile.email, style: const TextStyle(color: AppColors.midGrey, fontSize: 13))),
          const SizedBox(height: 8),
          Center(
            child: Chip(label: Text(profile.role.name.toUpperCase())),
          ),
          const SizedBox(height: 32),
          if (profile.role.name == 'seller')
            ListTile(
              tileColor: AppColors.richBlack,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.darkGrey)),
              leading: Icon(
                profile.isVerifiedSeller ? Icons.verified : Icons.hourglass_empty,
                color: profile.isVerifiedSeller ? AppColors.success : AppColors.warning,
              ),
              title: Text(profile.isVerifiedSeller ? 'Verified Seller' : 'Verification pending',
                  style: const TextStyle(color: AppColors.white)),
              subtitle: const Text('Admin reviews new sellers periodically', style: TextStyle(color: AppColors.midGrey)),
            ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            onPressed: () => context.read<AppState>().signOut(),
          ),
        ],
      ),
    );
  }
}
