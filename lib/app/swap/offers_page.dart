import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme.dart';
import 'chat_page.dart';
import 'item_widgets.dart';
import 'swap_controller.dart';
import 'swap_models.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final swap = Get.find<SwapController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'عروض المقايضة',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'تابع عروضك وتحدث مع الطرف الآخر',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final offers = swap.offers;
            if (offers.isEmpty) {
              return const EmptyState(
                icon: Icons.swap_horiz_rounded,
                title: 'لا توجد عروض بعد',
                subtitle: 'استكشف الأغراض وأرسل أول عرض مقايضة.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              itemCount: offers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _OfferCard(offer: offers[index], swap: swap),
            );
          }),
        ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer, required this.swap});
  final SwapOffer offer;
  final SwapController swap;

  @override
  Widget build(BuildContext context) {
    final incoming = offer.ownerId == swap.uid;
    final otherName = incoming ? offer.requesterName : offer.ownerName;
    final status = switch (offer.status) {
      'pending' => 'بانتظار الرد',
      'accepted' => 'مقبول · رتبوا التسليم',
      'declined' => 'مرفوض',
      'cancelled' => 'ملغي',
      'completed' => 'مكتمل',
      _ => offer.status,
    };
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BadalColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  incoming
                      ? 'عرض وارد من $otherName'
                      : 'عرض مرسل إلى $otherName',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: BadalColors.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: BadalColors.mint,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: BadalColors.pine,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"${offer.offeredTitle}"  ⇄  "${offer.targetTitle}"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: BadalColors.forest,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            incoming
                ? 'تقدم لك أغراض الطرف الآخر مقابل غرضك.'
                : 'قدمت غرضك مقابل غرض الطرف الآخر.',
            style: const TextStyle(color: BadalColors.muted, fontSize: 12),
          ),
          if (offer.status == 'pending' || offer.status == 'accepted') ...[
            const Divider(height: 26),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ChatPage(offer: offer)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
                  label: const Text('محادثة'),
                ),
                if (incoming && offer.status == 'pending') ...[
                  FilledButton(
                    onPressed: () =>
                        _change(context, 'accepted', 'قبول عرض المقايضة؟'),
                    child: const Text('قبول'),
                  ),
                  TextButton(
                    onPressed: () =>
                        _change(context, 'declined', 'رفض عرض المقايضة؟'),
                    child: const Text('رفض'),
                  ),
                ],
                if (!incoming && offer.status == 'pending')
                  TextButton(
                    onPressed: () =>
                        _change(context, 'cancelled', 'إلغاء العرض؟'),
                    child: const Text('إلغاء العرض'),
                  ),
                if (incoming && offer.status == 'accepted')
                  FilledButton(
                    onPressed: () => _change(
                      context,
                      'completed',
                      'هل استلم الطرفان الأغراض بالفعل؟',
                    ),
                    child: const Text('إكمال المقايضة'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _change(
    BuildContext context,
    String status,
    String question,
  ) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(question),
        content: status == 'accepted'
            ? const Text(
                'سيُحجز الغرضان لهذه المقايضة. استخدم المحادثة للاتفاق على المكان والوقت.',
              )
            : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('تراجع'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    if (yes != true || !context.mounted) return;
    final error = await swap.run(
      () => swap.repository.changeOfferStatus(offer, status, swap.uid),
    );
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}
