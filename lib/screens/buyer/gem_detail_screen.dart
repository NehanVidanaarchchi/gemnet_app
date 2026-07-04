import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/gem_model.dart';
import '../../services/app_state.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../chat/chat_screen.dart';

class GemDetailScreen extends StatelessWidget {
  final GemModel gem;
  const GemDetailScreen({super.key, required this.gem});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AppState>().currentUserProfile;
    final isOwnListing = me?.uid == gem.sellerId;
    final isSoldOut = gem.status == GemStatus.soldout;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.black,
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: gem.imageUrls.isNotEmpty
                  ? PageView(
                      children: gem.imageUrls
                          .map((url) => CachedNetworkImage(imageUrl: url, fit: BoxFit.cover))
                          .toList(),
                    )
                  : Container(color: AppColors.charcoal, child: const Icon(Icons.diamond_outlined, size: 64)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(gem.title.isNotEmpty ? gem.title : gem.type,
                            style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      if (isSoldOut)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
                          child: const Text('SOLD OUT', style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Certificate ID: ${gem.gemId}', style: const TextStyle(color: AppColors.lightGrey)),
                  const SizedBox(height: 16),
                  Text('${gem.currency} ${gem.price.toStringAsFixed(0)}',
                      style: const TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _specGrid(),
                  const SizedBox(height: 20),
                  const Text('Description', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(gem.description.isNotEmpty ? gem.description : 'No description provided.',
                      style: const TextStyle(color: AppColors.lightGrey, height: 1.4)),
                  const SizedBox(height: 24),
                  const Text('Certificate QR', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: AppColors.white,
                      child: QrImageView(data: gem.gemId, size: 140, backgroundColor: AppColors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text('Share ID "${gem.gemId}" so anyone can verify this gem',
                        style: const TextStyle(color: AppColors.midGrey, fontSize: 11)),
                  ),
                  const SizedBox(height: 28),
                  if (!isOwnListing && !isSoldOut && me != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Chat with seller'),
                        onPressed: () async {
                          final fs = FirestoreService();
                          final chatId = await fs.getOrCreateChat(
                            buyerId: me.uid,
                            buyerName: me.name,
                            sellerId: gem.sellerId,
                            sellerName: gem.sellerName,
                            gemDocId: gem.id,
                            gemTitle: gem.title.isNotEmpty ? gem.title : gem.type,
                            gemImage: gem.imageUrls.isNotEmpty ? gem.imageUrls.first : null,
                          );
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatId: chatId,
                                  otherPartyName: gem.sellerName,
                                  gemTitle: gem.title.isNotEmpty ? gem.title : gem.type,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _specGrid() {
    final specs = {
      'Type': gem.type,
      'Color': gem.color,
      'Weight': '${gem.weightCarat.toStringAsFixed(2)} ct',
      'Cut': gem.cut,
      'Transparency': gem.transparency,
      'Origin (est.)': gem.originGuess,
      'Clarity notes': gem.clarityNotes,
    };
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: specs.entries
          .where((e) => e.value.isNotEmpty)
          .map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.richBlack,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkGrey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key, style: const TextStyle(color: AppColors.midGrey, fontSize: 10)),
                    Text(e.value, style: const TextStyle(color: AppColors.white, fontSize: 13)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
