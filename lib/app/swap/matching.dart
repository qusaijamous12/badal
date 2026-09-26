import 'swap_models.dart';

int matchScore(SwapItem candidate, List<SwapItem> mine) {
  if (mine.isEmpty) return 0;
  final targetWords = _words('${candidate.wanted} ${candidate.title}');
  var score = 0;
  for (final item in mine) {
    if (!item.available) continue;
    final myWords = _words('${item.title} ${item.category}');
    final candidateWords = _words('${candidate.title} ${candidate.category}');
    final desiredWords = _words(item.wanted);
    var current = 0;
    if (candidate.wanted.isNotEmpty && candidate.wanted == item.category) {
      current += 35;
    }
    if (item.wanted.isNotEmpty && item.wanted == candidate.category) {
      current += 35;
    }
    current += targetWords.intersection(myWords).length * 12;
    current += desiredWords.intersection(candidateWords).length * 12;
    if (current > score) score = current;
  }
  return score.clamp(0, 100);
}

Set<String> _words(String value) => value
    .toLowerCase()
    .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
    .where((word) => word.length > 2)
    .toSet();
