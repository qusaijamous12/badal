import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth/auth_controller.dart';
import '../theme.dart';
import 'item_detail_page.dart';
import 'item_widgets.dart';
import 'matching.dart';
import 'swap_controller.dart';
import 'swap_models.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final swap = Get.find<SwapController>();
    final name =
        Get.find<AuthController>().user.value?.displayName?.split(' ').first ??
        'صديقنا';
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: BadalColors.forest,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'بدل',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: BadalColors.forest,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'مرحبًا، $name 👋',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  'اكتشف ما يمكنك مبادلته اليوم',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 22),
                TextField(
                  onChanged: (value) => swap.search.value = value,
                  decoration: const InputDecoration(
                    hintText: 'ابحث عن غرض أو فئة...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 17),
                CategoryFilters(category: swap.category),
                const SizedBox(height: 23),
                Text(
                  'أغراض للتبادل',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
        Obx(() {
          final entries = swap.discovered;
          if (entries.isEmpty) {
            return const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'لا توجد أغراض الآن',
                subtitle: 'جرّب فئة أخرى أو عد لاحقًا لاكتشاف عروض جديدة.',
              ),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                final count = width > 700
                    ? 4
                    : width > 450
                    ? 3
                    : 2;
                return SliverGrid.builder(
                  itemCount: entries.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,
                    crossAxisSpacing: 11,
                    mainAxisSpacing: 11,
                    mainAxisExtent: 235,
                  ),
                  itemBuilder: (context, index) {
                    final item = entries[index];
                    return ItemCard(
                      item: item,
                      score: matchScore(item, swap.availableMine),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ItemDetailPage(itemId: item.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

class CategoryFilters extends StatelessWidget {
  const CategoryFilters({super.key, required this.category});

  final RxString category;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: Obx(() {
      // Read the observable in this builder, before ListView calls itemBuilder.
      final selectedCategory = category.value;
      return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCategories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final label = index == 0 ? 'الكل' : itemCategories[index - 1];
          final selected = selectedCategory == label;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => category.value = label,
            selectedColor: BadalColors.mint,
            labelStyle: TextStyle(
              color: selected ? BadalColors.forest : BadalColors.muted,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
            side: const BorderSide(color: BadalColors.line),
          );
        },
      );
    }),
  );
}
