import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth/auth_controller.dart';
import '../theme.dart';
import 'item_widgets.dart';
import 'swap_controller.dart';
import 'swap_models.dart';

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({super.key, required this.itemId});
  final String itemId;

  @override
  Widget build(BuildContext context) {
    final swap = Get.find<SwapController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الغرض'),
        backgroundColor: BadalColors.cream,
      ),
      body: Obx(() {
        final matches = swap.items.where((item) => item.id == itemId);
        if (matches.isEmpty) {
          return const EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'الغرض غير متاح',
            subtitle: 'ربما حذفه صاحبه.',
          );
        }
        final item = matches.first;
        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
                children: [
                  ItemImage(item.imageBytes, height: 275),
                  const SizedBox(height: 22),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(item.category),
                        backgroundColor: BadalColors.mint,
                        side: BorderSide.none,
                      ),
                      Chip(
                        label: Text(item.condition),
                        backgroundColor: BadalColors.mint,
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                  const SizedBox(height: 19),
                  Text(
                    'عن الغرض',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 23),
                  Text(
                    'يرغب في المقابل',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.wanted,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 21),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: BadalColors.mint,
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: BadalColors.pine,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item.ownerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: BadalColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (item.ownerId != swap.uid)
                    ElevatedButton(
                      onPressed: item.available
                          ? () => _offer(context, item, swap)
                          : null,
                      child: Text(
                        item.available
                            ? 'اقترح مقايضة'
                            : 'هذا الغرض غير متاح حاليًا',
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _offer(
    BuildContext context,
    SwapItem target,
    SwapController swap,
  ) async {
    final mine = swap.availableMine;
    if (mine.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أضف غرضًا إلى خزانتك أولًا حتى تتمكن من المقايضة.'),
        ),
      );
      return;
    }
    final offered = await showModalBottomSheet<SwapItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختر غرضًا تقدمه',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 5),
              const Text('سيصل عرضك لصاحب الغرض ليراجعه.'),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: mine.length,
                  itemBuilder: (_, index) {
                    final item = mine[index];
                    return ListTile(
                      leading: SizedBox(
                        width: 52,
                        child: ItemImage(item.imageBytes, height: 52),
                      ),
                      title: Text(item.title),
                      subtitle: Text(item.category),
                      trailing: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15,
                      ),
                      onTap: () => Navigator.pop(sheetContext, item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (offered == null || !context.mounted) return;
    if (swap.offers.any(
      (offer) =>
          offer.targetItemId == target.id &&
          offer.offeredItemId == offered.id &&
          offer.status == 'pending',
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لديك عرض معلّق لهذين الغرضين بالفعل.')),
      );
      return;
    }
    final name =
        Get.find<AuthController>().user.value?.displayName ?? 'عضو بدل';
    final error = await swap.run(
      () => swap.repository.sendOffer(
        target: target,
        offered: offered,
        requesterName: name,
      ),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'أرسلنا عرض المقايضة. يمكنك متابعته من تبويب العروض.',
        ),
      ),
    );
    if (error == null) Navigator.of(context).pop();
  }
}
