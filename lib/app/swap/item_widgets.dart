import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme.dart';
import 'swap_models.dart';

class ItemImage extends StatelessWidget {
  const ItemImage(this.bytes, {super.key, this.height = 155});
  final Uint8List? bytes;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: SizedBox(
      width: double.infinity,
      height: height,
      child: bytes == null
          ? Container(
              color: BadalColors.mint,
              child: const Icon(
                Icons.inventory_2_outlined,
                color: BadalColors.pine,
                size: 52,
              ),
            )
          : Image.memory(
              bytes!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: BadalColors.mint,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: BadalColors.pine,
                ),
              ),
            ),
    ),
  );
}

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.score,
  });
  final SwapItem item;
  final VoidCallback onTap;
  final int? score;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(22),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BadalColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ItemImage(item.imageBytes),
              if (score != null && score! > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: BadalColors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'توافق $score%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: BadalColors.forest,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: BadalColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${item.category} · ${item.condition}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: BadalColors.muted),
          ),
          if (!item.available)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                item.status == 'reserved' ? 'قيد المقايضة' : 'تمت المقايضة',
                style: const TextStyle(
                  color: BadalColors.pine,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: BadalColors.mint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: BadalColors.pine),
          ),
          const SizedBox(height: 19),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ),
  );
}
