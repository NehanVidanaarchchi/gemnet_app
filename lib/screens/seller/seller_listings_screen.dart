import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/app_state.dart';
import '../../services/firestore_service.dart';
import '../../models/gem_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_widget.dart';
import 'add_gem_screen.dart';

class SellerListingsScreen extends StatelessWidget {
  const SellerListingsScreen({super.key});

  Color _statusColor(GemStatus s) {
    switch (s) {
      case GemStatus.approved:
        return AppColors.success;
      case GemStatus.pending:
        return AppColors.warning;
      case GemStatus.rejected:
        return AppColors.error;
      case GemStatus.soldout:
        return AppColors.midGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AppState>().currentUserProfile;
    if (me == null) return const SizedBox.shrink();
    final firestore = FirestoreService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text('My Listings', style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: StreamBuilder<List<GemModel>>(
            stream: firestore.watchSellerGems(me.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const InlineLoading();
              final gems = snapshot.data!;
              if (gems.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No listings yet. Tap "Add Gem" to create your first listing.',
                        textAlign: TextAlign.center, style: TextStyle(color: AppColors.midGrey)),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                itemCount: gems.length,
                itemBuilder: (context, i) {
                  final gem = gems[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: gem.imageUrls.isNotEmpty
                                ? CachedNetworkImage(imageUrl: gem.imageUrls.first, width: 64, height: 64, fit: BoxFit.cover)
                                : Container(width: 64, height: 64, color: AppColors.charcoal, child: const Icon(Icons.diamond_outlined, color: AppColors.midGrey)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(gem.title.isNotEmpty ? gem.title : gem.type,
                                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('${gem.gemId} • ${gem.currency} ${gem.price.toStringAsFixed(0)}',
                                    style: const TextStyle(color: AppColors.midGrey, fontSize: 12)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _statusColor(gem.status).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: _statusColor(gem.status)),
                                      ),
                                      child: Text(gem.status.name.toUpperCase(),
                                          style: TextStyle(color: _statusColor(gem.status), fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                if (gem.status == GemStatus.rejected && (gem.rejectionReason ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text('Reason: ${gem.rejectionReason}',
                                        style: const TextStyle(color: AppColors.error, fontSize: 11)),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.lightGrey, size: 20),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AddGemScreen(existingGem: gem)),
                                ),
                              ),
                              if (gem.status == GemStatus.approved)
                                IconButton(
                                  icon: const Icon(Icons.check_circle_outline, color: AppColors.warning, size: 20),
                                  tooltip: 'Mark sold out',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        backgroundColor: AppColors.richBlack,
                                        title: const Text('Mark as sold out?', style: TextStyle(color: AppColors.white)),
                                        content: const Text('Buyers will no longer be able to purchase this gem.',
                                            style: TextStyle(color: AppColors.midGrey)),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await firestore.markSoldOut(gem.id);
                                    }
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
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
