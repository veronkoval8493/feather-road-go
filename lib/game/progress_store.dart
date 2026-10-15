import 'board_state.dart';

/// Outcome of one round, handed to the result screen.
class RoundResult {
  const RoundResult({
    required this.schemeIndex,
    required this.won,
    required this.stars,
    required this.grain,
    required this.movesUsed,
    required this.checksLeft,
    required this.outOfMoves,
    required this.board,
  });

  final int schemeIndex;
  final bool won;
  final int stars;
  final int grain;
  final int movesUsed;
  final int checksLeft;
  final bool outOfMoves;

  /// Board as it stood when the round ended, used for the mini preview.
  final BoardState board;
}

/// In-memory progression. Cold start resets it, which keeps the dependency set
/// at flutter + cupertino_icons.
class ProgressStore {
  ProgressStore._();

  static final ProgressStore instance = ProgressStore._();

  final Map<int, int> _stars = <int, int>{};
  int bestGrain = 0;

  int starsFor(int schemeIndex) => _stars[schemeIndex] ?? 0;

  int get totalStars =>
      _stars.values.fold<int>(0, (int sum, int value) => sum + value);

  bool isUnlocked(int schemeIndex) =>
      schemeIndex == 0 || starsFor(schemeIndex - 1) >= 1;

  void record(RoundResult result) {
    if (result.stars > starsFor(result.schemeIndex)) {
      _stars[result.schemeIndex] = result.stars;
    }
    if (result.grain > bestGrain) {
      bestGrain = result.grain;
    }
  }
}
