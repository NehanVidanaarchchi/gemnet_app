import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/gem_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gem_card.dart';
import '../../widgets/loading_widget.dart';
import 'gem_detail_screen.dart';

class BrowseGemsTab extends StatefulWidget {
  const BrowseGemsTab({super.key});

  @override
  State<BrowseGemsTab> createState() => _BrowseGemsTabState();
}

class _BrowseGemsTabState extends State<BrowseGemsTab> {
  final _firestore = FirestoreService();
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.emerald, AppColors.emeraldDark]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.diamond, color: AppColors.black, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Discover rare gems', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -.4)),
                    Text('Verified stones from trusted sellers', style: TextStyle(color: AppColors.midGrey, fontSize: 12)),
                  ])),
                  IconButton.filledTonal(onPressed: null, icon: const Icon(Icons.tune_rounded)),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  hintText: 'Search gemstones, colors, cuts...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: (v) => setState(() => _search = v.toLowerCase()),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<GemModel>>(
            stream: _firestore.watchApprovedGems(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const InlineLoading();
              var gems = snapshot.data!;
              if (_search.isNotEmpty) {
                gems = gems
                    .where((g) =>
                        g.title.toLowerCase().contains(_search) ||
                        g.type.toLowerCase().contains(_search) ||
                        g.color.toLowerCase().contains(_search))
                    .toList();
              }
              if (gems.isEmpty) {
                return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.search_off_rounded, color: AppColors.midGrey, size: 42),
                  SizedBox(height: 12),
                  Text('No gems found', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Try a different type or color', style: TextStyle(color: AppColors.midGrey)),
                ]));
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.70,
                ),
                itemCount: gems.length,
                itemBuilder: (context, i) {
                  final gem = gems[i];
                  return GemCard(
                    gem: gem,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GemDetailScreen(gem: gem)),
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
