import 'package:badal/app/swap/matching.dart';
import 'package:badal/app/swap/swap_models.dart';
import 'package:flutter_test/flutter_test.dart';

SwapItem item({
  required String id,
  required String title,
  required String category,
  required String wanted,
  String status = 'available',
}) => SwapItem(
  id: id,
  ownerId: id,
  ownerName: 'عضو',
  title: title,
  description: 'وصف تجريبي للغرض',
  category: category,
  condition: 'جيدة',
  wanted: wanted,
  imageBytes: null,
  status: status,
  createdAt: null,
);

void main() {
  test('reciprocal needs rank above unrelated items', () {
    final mine = [
      item(
        id: 'mine',
        title: 'كتاب تاريخ',
        category: 'كتب',
        wanted: 'إلكترونيات',
      ),
    ];
    final reciprocal = item(
      id: 'match',
      title: 'سماعات',
      category: 'إلكترونيات',
      wanted: 'كتب',
    );
    final unrelated = item(
      id: 'other',
      title: 'كرسي',
      category: 'أثاث',
      wanted: 'ملابس',
    );

    expect(
      matchScore(reciprocal, mine),
      greaterThan(matchScore(unrelated, mine)),
    );
    expect(matchScore(reciprocal, mine), greaterThanOrEqualTo(70));
  });

  test('reserved items do not create matches', () {
    final mine = [
      item(
        id: 'mine',
        title: 'كتاب',
        category: 'كتب',
        wanted: 'إلكترونيات',
        status: 'reserved',
      ),
    ];
    final other = item(
      id: 'other',
      title: 'سماعات',
      category: 'إلكترونيات',
      wanted: 'كتب',
    );
    expect(matchScore(other, mine), 0);
  });
}
