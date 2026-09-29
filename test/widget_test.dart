import 'package:feather_road_go/game/board_logic.dart';
import 'package:feather_road_go/game/levels.dart';
import 'package:feather_road_go/theme.dart';
import 'package:feather_road_go/widgets/buttons.dart';
import 'package:feather_road_go/widgets/stat_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('board generation', () {
    test('every scheme is solvable by construction', () {
      for (final SchemeModel scheme in kSchemes) {
        final BoardState board = buildBoard(scheme);
        final Map<int, List<int>> solved =
            completedRoutes(board.solvedCopy());
        expect(
          solved.length,
          scheme.pairs,
          reason: '${scheme.name} solved layout must link every pair',
        );
      }
    });

    test('boards start scrambled and grant slack moves', () {
      for (final SchemeModel scheme in kSchemes) {
        final BoardState board = buildBoard(scheme);
        expect(board.minMoves, greaterThan(0));
        expect(board.movesLeft, board.minMoves + scheme.slack);
        expect(completedRoutes(board).length, lessThan(scheme.pairs));
      }
    });

    test('bands cover the whole grid exactly once', () {
      for (final SchemeModel scheme in kSchemes) {
        final List<int> seen = <int>[];
        for (final List<int> path in carvePaths(scheme)) {
          seen.addAll(path);
        }
        expect(seen.length, scheme.rows * scheme.cols);
        expect(seen.toSet().length, seen.length);
      }
    });
  });

  testWidgets('primary button reports taps', (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Center(
            child: PrimaryButton(
              label: 'PLAY NOW',
              icon: Icons.play_arrow,
              gradient: const <Color>[AppColors.gold, AppColors.goldDeep],
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );

    expect(find.text('PLAY NOW'), findsOneWidget);
    await tester.tap(find.text('PLAY NOW'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('stat row hides itself below two pills',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatPillRow(
            pills: <StatPill>[
              StatPill(value: '2/2', label: 'PAIRS', accent: AppColors.green),
            ],
          ),
        ),
      ),
    );
    expect(find.text('PAIRS'), findsNothing);
  });
}
