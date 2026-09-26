import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'matching.dart';
import 'swap_models.dart';
import 'swap_repository.dart';

class SwapController extends GetxController {
  SwapController({required this.uid, SwapRepository? repository})
    : repository = repository ?? SwapRepository();

  final String uid;
  final SwapRepository repository;
  final items = <SwapItem>[].obs;
  final offers = <SwapOffer>[].obs;
  final selectedTab = 0.obs;
  final search = ''.obs;
  final category = 'الكل'.obs;
  final busy = false.obs;
  final feedError = RxnString();
  StreamSubscription<List<SwapItem>>? _itemSubscription;
  StreamSubscription<List<SwapOffer>>? _ownerSubscription;
  StreamSubscription<List<SwapOffer>>? _requesterSubscription;
  List<SwapOffer> _ownerOffers = [];
  List<SwapOffer> _requesterOffers = [];

  @override
  void onInit() {
    super.onInit();
    _itemSubscription = repository.watchItems().listen(
      (value) {
        items.assignAll(value);
        feedError.value = null;
      },
      onError: (_) => feedError.value =
          'تعذر تحميل الأغراض. تحقق من اتصالك وقواعد Firestore.',
    );
    _ownerSubscription = repository.watchOffersForOwner(uid).listen(
      (value) {
        _ownerOffers = value;
        _mergeOffers();
      },
      onError: (_) =>
          feedError.value = 'تعذر تحميل العروض. تحقق من قواعد Firestore.',
    );
    _requesterSubscription = repository.watchOffersForRequester(uid).listen(
      (value) {
        _requesterOffers = value;
        _mergeOffers();
      },
      onError: (_) =>
          feedError.value = 'تعذر تحميل العروض. تحقق من قواعد Firestore.',
    );
  }

  void _mergeOffers() {
    final byId = <String, SwapOffer>{
      for (final offer in _ownerOffers) offer.id: offer,
      for (final offer in _requesterOffers) offer.id: offer,
    };
    final sorted = byId.values.toList()
      ..sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
    offers.assignAll(sorted);
  }

  List<SwapItem> get myItems =>
      items.where((item) => item.ownerId == uid).toList();
  List<SwapItem> get availableMine =>
      myItems.where((item) => item.available).toList();
  List<SwapItem> get discovered {
    final query = search.value.trim().toLowerCase();
    final result = items
        .where(
          (item) =>
              item.ownerId != uid &&
              item.available &&
              (category.value == 'الكل' || item.category == category.value) &&
              (query.isEmpty ||
                  '${item.title} ${item.description} ${item.category} ${item.wanted}'
                      .toLowerCase()
                      .contains(query)),
        )
        .toList();
    result.sort((a, b) {
      final scores = matchScore(
        b,
        availableMine,
      ).compareTo(matchScore(a, availableMine));
      return scores != 0
          ? scores
          : (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
    });
    return result;
  }

  bool hasPendingOffer(String itemId) => offers.any(
    (offer) =>
        offer.status == 'pending' &&
        (offer.targetItemId == itemId || offer.offeredItemId == itemId),
  );

  Future<String?> run(Future<void> Function() task) async {
    if (busy.value) return 'انتظر حتى تنتهي العملية الحالية.';
    busy.value = true;
    try {
      await task();
      return null;
    } on StateError catch (error) {
      return error.message;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        return 'ليس لديك صلاحية لهذه العملية. تحقق من قواعد Firebase.';
      }
      if (error.code == 'unavailable') {
        return 'الخدمة غير متاحة حاليًا. تحقق من اتصالك.';
      }
      return 'تعذر إكمال العملية: ${error.message ?? error.code}';
    } catch (_) {
      return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
    } finally {
      busy.value = false;
    }
  }

  @override
  void onClose() {
    _itemSubscription?.cancel();
    _ownerSubscription?.cancel();
    _requesterSubscription?.cancel();
    super.onClose();
  }
}
