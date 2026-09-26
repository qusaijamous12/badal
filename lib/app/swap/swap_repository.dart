import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import 'image_processing.dart';
import 'swap_models.dart';

class SwapRepository {
  SwapRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<SwapItem>> watchItems() => _db
      .collection('items')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(SwapItem.fromDoc).toList());

  Stream<List<SwapOffer>> watchOffersForOwner(String uid) => _db
      .collection('offers')
      .where('ownerId', isEqualTo: uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(SwapOffer.fromDoc).toList());

  Stream<List<SwapOffer>> watchOffersForRequester(String uid) => _db
      .collection('offers')
      .where('requesterId', isEqualTo: uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(SwapOffer.fromDoc).toList());

  Future<String?> suggestCategory(String path) async {
    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.6),
    );
    try {
      final labels = await labeler.processImage(InputImage.fromFilePath(path));
      final text = labels.map((label) => label.label.toLowerCase()).join(' ');
      if (RegExp(
        r'phone|computer|laptop|electronics|headphone|camera',
      ).hasMatch(text)) {
        return 'إلكترونيات';
      }
      if (RegExp(r'clothing|shirt|dress|shoe|jacket|fashion').hasMatch(text)) {
        return 'ملابس';
      }
      if (RegExp(r'book|publication|textbook').hasMatch(text)) return 'كتب';
      if (RegExp(r'furniture|chair|table|sofa|desk').hasMatch(text)) {
        return 'أثاث';
      }
      if (RegExp(r'kitchen|appliance|cookware|home').hasMatch(text)) {
        return 'أدوات منزلية';
      }
      if (RegExp(r'sport|ball|bicycle|fitness').hasMatch(text)) return 'رياضة';
      if (RegExp(r'toy|game|doll').hasMatch(text)) return 'ألعاب';
      return null;
    } finally {
      await labeler.close();
    }
  }

  Future<void> saveItem({
    required String uid,
    required String ownerName,
    required String title,
    required String description,
    required String category,
    required String condition,
    required String wanted,
    String? imagePath,
    SwapItem? existing,
  }) async {
    if (existing != null && (existing.ownerId != uid || !existing.available)) {
      throw StateError('لا يمكن تعديل هذا الغرض الآن.');
    }
    final ref = existing == null
        ? _db.collection('items').doc()
        : _db.collection('items').doc(existing.id);
    Uint8List? imageBytes = existing?.imageBytes;
    if (imagePath != null) {
      imageBytes = await compute(
        compressItemImage,
        await File(imagePath).readAsBytes(),
      );
    }
    if (imageBytes == null) throw StateError('أضف صورة للغرض.');
    final values = <String, dynamic>{
      'ownerId': uid,
      'ownerName': ownerName,
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'condition': condition,
      'wanted': wanted.trim(),
      'image': Blob(imageBytes),
      'status': 'available',
    };
    if (existing == null) values['createdAt'] = FieldValue.serverTimestamp();
    await ref.set(values, SetOptions(merge: true));
  }

  Future<void> deleteItem(SwapItem item, String uid) async {
    if (item.ownerId != uid || !item.available) {
      throw StateError('لا يمكن حذف هذا الغرض الآن.');
    }
    await _db.collection('items').doc(item.id).delete();
  }

  Future<void> sendOffer({
    required SwapItem target,
    required SwapItem offered,
    required String requesterName,
  }) async {
    if (target.ownerId == offered.ownerId) {
      throw StateError('اختر غرضًا من مستخدم آخر.');
    }
    final offerRef = _db.collection('offers').doc();
    final targetRef = _db.collection('items').doc(target.id);
    final offeredRef = _db.collection('items').doc(offered.id);
    await _db.runTransaction((tx) async {
      final targetSnap = await tx.get(targetRef);
      final offeredSnap = await tx.get(offeredRef);
      if (targetSnap.data()?['status'] != 'available' ||
          offeredSnap.data()?['status'] != 'available') {
        throw StateError('أحد الغرضين لم يعد متاحًا للمقايضة.');
      }
      if (targetSnap.data()?['ownerId'] != target.ownerId ||
          offeredSnap.data()?['ownerId'] != offered.ownerId) {
        throw StateError('تعذر التحقق من ملكية الأغراض.');
      }
      tx.set(offerRef, {
        'targetItemId': target.id,
        'offeredItemId': offered.id,
        'targetTitle': target.title,
        'offeredTitle': offered.title,
        'ownerId': target.ownerId,
        'requesterId': offered.ownerId,
        'ownerName': target.ownerName,
        'requesterName': requesterName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> changeOfferStatus(
    SwapOffer offer,
    String next,
    String uid,
  ) async {
    final offerRef = _db.collection('offers').doc(offer.id);
    if (next == 'declined' || next == 'cancelled') {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(offerRef);
        if (snap.data()?['status'] != 'pending') {
          throw StateError('تم تغيير حالة العرض بالفعل.');
        }
        if (next == 'declined' && snap.data()?['ownerId'] != uid ||
            next == 'cancelled' && snap.data()?['requesterId'] != uid) {
          throw StateError('لا يمكنك تغيير هذا العرض.');
        }
        tx.update(offerRef, {'status': next});
      });
      return;
    }
    if (uid != offer.ownerId) {
      throw StateError('قبول المقايضة وإكمالها لصاحب الغرض المطلوب.');
    }
    final targetRef = _db.collection('items').doc(offer.targetItemId);
    final offeredRef = _db.collection('items').doc(offer.offeredItemId);
    await _db.runTransaction((tx) async {
      final offerSnap = await tx.get(offerRef);
      final targetSnap = await tx.get(targetRef);
      final offeredSnap = await tx.get(offeredRef);
      final expected = next == 'accepted' ? 'pending' : 'accepted';
      final itemExpected = next == 'accepted' ? 'available' : 'reserved';
      if (offerSnap.data()?['status'] != expected ||
          targetSnap.data()?['status'] != itemExpected ||
          offeredSnap.data()?['status'] != itemExpected) {
        throw StateError(
          'تغيرت حالة العرض أو أحد الغرضين. حدّث الصفحة وحاول مجددًا.',
        );
      }
      if (targetSnap.data()?['ownerId'] != offer.ownerId ||
          offeredSnap.data()?['ownerId'] != offer.requesterId) {
        throw StateError('تعذر التحقق من ملكية الأغراض.');
      }
      tx.update(offerRef, {'status': next});
      final status = next == 'accepted' ? 'reserved' : 'exchanged';
      tx.update(targetRef, {'status': status, 'activeOfferId': offer.id});
      tx.update(offeredRef, {'status': status, 'activeOfferId': offer.id});
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessages(String offerId) =>
      _db
          .collection('offers')
          .doc(offerId)
          .collection('messages')
          .orderBy('createdAt')
          .snapshots();

  Future<void> sendMessage(String offerId, String uid, String body) async {
    final text = body.trim();
    if (text.isEmpty || text.length > 1000) {
      throw StateError('الرسالة فارغة أو طويلة جدًا.');
    }
    await _db.collection('offers').doc(offerId).collection('messages').add({
      'senderId': uid,
      'body': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
