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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('GemNet', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  hintText: 'Search by type, color...',
                  prefixIcon: Icon(Icons.search, color: AppColors.midGrey),
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
                return const Center(
                  child: Text('No gems found', style: TextStyle(color: AppColors.midGrey)),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.68,
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
