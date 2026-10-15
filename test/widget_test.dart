// Smoke tests for Feather Road Go: the splash hands off to the menu, and every
// generated scheme is solvable by replaying its stored solution.

import 'package:feather_road_go/game/board_state.dart';
import 'package:feather_road_go/game/scheme_generator.dart';
import 'package:feather_road_go/game/schemes.dart';
import 'package:feather_road_go/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Loader hands off to the menu', (WidgetTester tester) async {
    await tester.pumpWidget(const FeatherRoadGoApp());
    await tester.pump();

    expect(find.text('LOADING…'), findsOneWidget);
    expect(find.text('PLAY'), findsNothing);

    // Past the splash hand-off and its safety net.
    await tester.pump(const Duration(seconds: 41));
    await tester.pumpAndSettle();

    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('FARM MAP'), findsOneWidget);
  });

  test('every scheme is solvable and lands inside its turn band', () {
    for (int index = 0; index < kSchemes.length; index++) {
      final SchemeDef scheme = kSchemes[index];
      final BoardState board = generateBoard(scheme);

      final List<RouteTrace> start = board.traceAll();
      expect(
        board.isSolved(start, board.crossingsOf(start)),
        isFalse,
        reason: 'scheme ${scheme.number} starts already solved',
      );

      int turns = 0;
      while (board.firstUnsolvedPost() != -1 && turns < 200) {
        board.rotate(board.firstUnsolvedPost());
        turns++;
      }
      final List<RouteTrace> end = board.traceAll();
      expect(
        board.isSolved(end, board.crossingsOf(end)),
        isTrue,
        reason: 'scheme ${scheme.number} is not solvable',
      );
      expect(turns, board.parMoves);
      expect(turns, greaterThanOrEqualTo(scheme.minTurns));
      expect(turns, lessThanOrEqualTo(scheme.maxTurns));
    }
  });
}
