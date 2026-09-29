import 'package:feather_road_go/game/board_logic.dart';
import 'package:feather_road_go/game/levels.dart';
import 'package:feather_road_go/main.dart';
import 'package:feather_road_go/screens/game_over_screen.dart';
import 'package:feather_road_go/screens/game_screen.dart';
import 'package:feather_road_go/screens/menu_screen.dart';
import 'package:feather_road_go/screens/schemes_screen.dart';
import 'package:feather_road_go/screens/tutorial_screen.dart';
import 'package:feather_road_go/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 1x1 transparent PNG, served for every asset key so the layout can be
/// exercised without the generated artwork being present.
const List<int> _pixelPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

class _StubBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('.bin') || key.endsWith('.json')) {
      // Empty asset manifest: every key resolves at scale 1.0.
      return const StandardMessageCodec().encodeMessage(<String, Object>{})!;
    }
    return ByteData.sublistView(Uint8List.fromList(_pixelPng));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => '';
}

Widget _host(Widget child) => DefaultAssetBundle(
      bundle: _StubBundle(),
      child: MaterialApp(theme: buildAppTheme(), home: child),
    );

Future<void> _withSurface(
  WidgetTester tester,
  Size size,
  Future<void> Function() body,
) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await body();
}

void main() {
  const List<Size> surfaces = <Size>[Size(360, 640), Size(411, 891)];

  for (final Size surface in surfaces) {
    testWidgets('board screen lays out at $surface', (WidgetTester tester) async {
      await _withSurface(tester, surface, () async {
        for (int i = 0; i < kSchemes.length; i++) {
          await tester.pumpWidget(
            _host(
              GameScreen(
                key: ValueKey<int>(i),
                schemeIndex: i,
                onFinish: (GameResult _) {},
                onBack: () {},
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull);
          expect(find.text('GO'), findsOneWidget);
        }
      });
    });

    testWidgets('result screen lays out at $surface', (WidgetTester tester) async {
      await _withSurface(tester, surface, () async {
        for (final bool win in <bool>[true, false]) {
          await tester.pumpWidget(
            _host(
              GameOverScreen(
                key: ValueKey<bool>(win),
                bestStars: 3,
                onPlayAgain: () {},
                onMenu: () {},
                result: GameResult(
                  win: win,
                  stars: win ? 3 : 0,
                  schemeIndex: 0,
                  pairsDone: win ? 2 : 1,
                  pairsTotal: 2,
                  movesLeft: 5,
                  rows: 5,
                  cols: 5,
                  solvedRoutes: completedRoutes(
                    buildBoard(kSchemes[0]).solvedCopy(),
                  ).values.toList(),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 700));
          expect(tester.takeException(), isNull);
          expect(find.text(win ? 'YOU WON!' : 'NO LUCK!'), findsOneWidget);
          expect(find.text('PLAY AGAIN'), findsOneWidget);
        }
      });
    });

    testWidgets('menu, schemes and tutorial lay out at $surface',
        (WidgetTester tester) async {
      await _withSurface(tester, surface, () async {
        await tester.pumpWidget(
          _host(
            MenuScreen(
              grain: 120,
              selectedScheme: 0,
              onSelectScheme: (int _) {},
              onPlay: () {},
              onSchemes: () {},
              onTutorial: () {},
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 700));
        expect(tester.takeException(), isNull);
        expect(find.text('PLAY NOW'), findsOneWidget);

        await tester.pumpWidget(
          _host(
            SchemesScreen(
              stars: List<int>.filled(kSchemes.length, 0),
              unlockedCount: 1,
              onSelect: (int _) {},
              onBack: () {},
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          _host(TutorialScreen(onBack: () {}, onBegin: () {})),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        expect(find.text('START PLAYING'), findsOneWidget);
      });
    });
  }

  testWidgets('three failed checks end the round with a result',
      (WidgetTester tester) async {
    await _withSurface(tester, const Size(411, 891), () async {
      GameResult? finished;
      await tester.pumpWidget(
        _host(
          GameScreen(
            schemeIndex: 0,
            onFinish: (GameResult r) => finished = r,
            onBack: () {},
          ),
        ),
      );
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('GO'));
        await tester.pump(const Duration(milliseconds: 600));
      }
      expect(finished, isNull, reason: 'board is held before the result');
      await tester.pump(const Duration(milliseconds: 5000));
      expect(finished, isNotNull);
      expect(finished!.win, isFalse);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('loader hands over to the menu after the splash window',
      (WidgetTester tester) async {
    await _withSurface(tester, const Size(411, 891), () async {
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: _StubBundle(),
          child: const FeatherRoadGoApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.text('LOADING…'), findsOneWidget);
      expect(find.text('PLAY NOW'), findsNothing);

      await tester.pump(const Duration(milliseconds: 7000));
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('PLAY NOW'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
