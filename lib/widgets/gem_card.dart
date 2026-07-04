import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/gem_model.dart';
import '../theme/app_theme.dart';

class GemCard extends StatelessWidget {
  final GemModel gem;
  final VoidCallback onTap;

  const GemCard({super.key, required this.gem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSoldOut = gem.status == GemStatus.soldout;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.richBlack,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkGrey),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  gem.imageUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: gem.imageUrls.first,
                          fit: BoxFit.cover,
                          placeholder: (c, _) => Container(color: AppColors.charcoal),
                          errorWidget: (c, _, _) => Container(
                            color: AppColors.charcoal,
                            child: const Icon(Icons.diamond_outlined, color: AppColors.midGrey),
                          ),
                        )
                      : Container(
                          color: AppColors.charcoal,
                          child: const Icon(Icons.diamond_outlined, color: AppColors.midGrey, size: 36),
                        ),
                  if (isSoldOut)
                    Container(
                      color: Colors.black.withValues(alpha: 0.6),
                      alignment: Alignment.center,
                      child: const Text(
                        'SOLD OUT',
                        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(gem.gemId, style: const TextStyle(color: AppColors.white, fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gem.title.isNotEmpty ? gem.title : gem.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gem.weightCarat.toStringAsFixed(2)} ct  •  ${gem.color}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.midGrey, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${gem.currency} ${gem.price.toStringAsFixed(0)}',
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
