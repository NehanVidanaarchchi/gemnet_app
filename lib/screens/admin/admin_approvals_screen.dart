import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/firestore_service.dart';
import '../../models/gem_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_widget.dart';

class AdminApprovalsScreen extends StatelessWidget {
  const AdminApprovalsScreen({super.key});

  Future<void> _reject(BuildContext context, FirestoreService fs, GemModel gem) async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.richBlack,
        title: const Text('Reject listing', style: TextStyle(color: AppColors.white)),
        content: TextField(
          controller: reasonCtrl,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(hintText: 'Reason (shown to seller)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, reasonCtrl.text.trim()), child: const Text('Reject')),
        ],
      ),
    );
    if (reason != null) {
      await fs.setGemStatus(gem.id, GemStatus.rejected, reason: reason.isEmpty ? 'Not specified' : reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text('Pending Approvals', style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: StreamBuilder<List<GemModel>>(
            stream: fs.watchPendingGems(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const InlineLoading();
              final gems = snapshot.data!;
              if (gems.isEmpty) {
                return const Center(child: Text('No pending listings 🎉', style: TextStyle(color: AppColors.midGrey)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: gems.length,
                itemBuilder: (context, i) {
                  final gem = gems[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: gem.imageUrls.isNotEmpty
                                    ? CachedNetworkImage(imageUrl: gem.imageUrls.first, width: 60, height: 60, fit: BoxFit.cover)
                                    : Container(width: 60, height: 60, color: AppColors.charcoal),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(gem.title.isNotEmpty ? gem.title : gem.type,
                                        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
                                    Text('by ${gem.sellerName} • ${gem.gemId}', style: const TextStyle(color: AppColors.midGrey, fontSize: 12)),
                                    Text('${gem.currency} ${gem.price.toStringAsFixed(0)} • ${gem.weightCarat} ct',
                                        style: const TextStyle(color: AppColors.lightGrey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(gem.description, style: const TextStyle(color: AppColors.midGrey, fontSize: 12), maxLines: 3, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _reject(context, fs, gem),
                                  child: const Text('Reject'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => fs.setGemStatus(gem.id, GemStatus.approved),
                                  child: const Text('Approve'),
                                ),
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
