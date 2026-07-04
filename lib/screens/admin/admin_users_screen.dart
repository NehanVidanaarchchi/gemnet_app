import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_widget.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text('Users', style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: fs.watchAllUsers(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const InlineLoading();
              final users = snapshot.data!;
              return ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final u = users[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.charcoal,
                      backgroundImage: u.photoUrl != null ? NetworkImage(u.photoUrl!) : null,
                      child: u.photoUrl == null ? const Icon(Icons.person, color: AppColors.midGrey) : null,
                    ),
                    title: Text(u.name, style: const TextStyle(color: AppColors.white)),
                    subtitle: Text('${u.email} • ${u.role.name}${u.isBanned ? " • BANNED" : ""}',
                        style: TextStyle(color: u.isBanned ? AppColors.error : AppColors.midGrey, fontSize: 12)),
                    trailing: PopupMenuButton<String>(
                      color: AppColors.richBlack,
                      icon: const Icon(Icons.more_vert, color: AppColors.lightGrey),
                      onSelected: (value) {
                        if (value == 'ban') fs.setUserBanned(u.uid, true);
                        if (value == 'unban') fs.setUserBanned(u.uid, false);
                        if (value == 'verify') fs.setSellerVerified(u.uid, true);
                        if (value == 'unverify') fs.setSellerVerified(u.uid, false);
                      },
                      itemBuilder: (context) => [
                        if (u.role == UserRole.seller && !u.isVerifiedSeller)
                          const PopupMenuItem(value: 'verify', child: Text('Verify seller', style: TextStyle(color: AppColors.white))),
                        if (u.role == UserRole.seller && u.isVerifiedSeller)
                          const PopupMenuItem(value: 'unverify', child: Text('Remove verification', style: TextStyle(color: AppColors.white))),
                        if (!u.isBanned)
                          const PopupMenuItem(value: 'ban', child: Text('Ban user', style: TextStyle(color: AppColors.error))),
                        if (u.isBanned)
                          const PopupMenuItem(value: 'unban', child: Text('Unban user', style: TextStyle(color: AppColors.success))),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
