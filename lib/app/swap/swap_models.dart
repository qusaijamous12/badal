import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class SwapItem {
  const SwapItem({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.wanted,
    required this.imageBytes,
    required this.status,
    required this.createdAt,
    this.activeOfferId,
  });

  final String id;
  final String ownerId;
  final String ownerName;
  final String title;
  final String description;
  final String category;
  final String condition;
  final String wanted;
  final Uint8List? imageBytes;
  final String status;
  final DateTime? createdAt;
  final String? activeOfferId;

  bool get available => status == 'available';

  factory SwapItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return SwapItem(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? 'عضو بدل',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'أخرى',
      condition: data['condition'] as String? ?? 'جيدة',
      wanted: data['wanted'] as String? ?? '',
      imageBytes: (data['image'] as Blob?)?.bytes,
      status: data['status'] as String? ?? 'available',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      activeOfferId: data['activeOfferId'] as String?,
    );
  }
}

class SwapOffer {
  const SwapOffer({
    required this.id,
    required this.targetItemId,
    required this.offeredItemId,
    required this.targetTitle,
    required this.offeredTitle,
    required this.ownerId,
    required this.requesterId,
    required this.ownerName,
    required this.requesterName,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String targetItemId;
  final String offeredItemId;
  final String targetTitle;
  final String offeredTitle;
  final String ownerId;
  final String requesterId;
  final String ownerName;
  final String requesterName;
  final String status;
  final DateTime? createdAt;

  factory SwapOffer.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return SwapOffer(
      id: doc.id,
      targetItemId: data['targetItemId'] as String? ?? '',
      offeredItemId: data['offeredItemId'] as String? ?? '',
      targetTitle: data['targetTitle'] as String? ?? '',
      offeredTitle: data['offeredTitle'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      requesterId: data['requesterId'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? 'عضو بدل',
      requesterName: data['requesterName'] as String? ?? 'عضو بدل',
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

const itemCategories = <String>[
  'إلكترونيات',
  'ملابس',
  'كتب',
  'أثاث',
  'أدوات منزلية',
  'رياضة',
  'ألعاب',
  'أخرى',
];

const itemConditions = <String>['جديد', 'ممتازة', 'جيدة', 'مستعملة'];
