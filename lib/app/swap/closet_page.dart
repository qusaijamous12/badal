import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme.dart';
import 'item_form_page.dart';
import 'item_widgets.dart';
import 'swap_controller.dart';

class ClosetPage extends StatelessWidget {
  const ClosetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final swap = Get.find<SwapController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خزانتي',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Obx(
                      () => Text(
                        '${swap.myItems.length} أغراض في خزانتك',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ItemFormPage())),
                icon: const Icon(Icons.add_rounded),
                tooltip: 'إضافة غرض',
                style: IconButton.styleFrom(
                  backgroundColor: BadalColors.forest,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final items = swap.myItems;
            if (items.isEmpty) {
              return EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'خزانتك تنتظر أول غرض',
                subtitle: 'أضف غرضًا لا تستخدمه وابدأ أول مقايضة.',
                action: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ItemFormPage()),
                  ),
                  child: const Text('إضافة غرض'),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 11),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: BadalColors.line),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 84,
                        child: ItemImage(item.imageBytes, height: 83),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: BadalColors.ink,
                              ),
                            ),
                            Text(
                              '${item.category} · ${item.condition}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: BadalColors.muted,
                              ),
                            ),
                            Text(
                              item.available
                                  ? 'متاح للمقايضة'
                                  : item.status == 'reserved'
                                  ? 'قيد المقايضة'
                                  : 'تمت المقايضة',
                              style: const TextStyle(
                                fontSize: 12,
                                color: BadalColors.pine,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (action) async {
                          if (action == 'edit') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ItemFormPage(item: item),
                              ),
                            );
                          } else {
                            if (swap.hasPendingOffer(item.id)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'عالج عروض المقايضة المعلقة قبل حذف الغرض.',
                                  ),
                                ),
                              );
                              return;
                            }
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('حذف الغرض؟'),
                                content: Text(
                                  'سيُحذف "${item.title}" من خزانتك.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('إلغاء'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('حذف'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm != true) return;
                            final error = await swap.run(
                              () => swap.repository.deleteItem(item, swap.uid),
                            );
                            if (error != null && context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(error)));
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          if (item.available)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('تعديل'),
                            ),
                          if (item.available)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('حذف'),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
