import 'package:flutter/material.dart';

import 'game/board_logic.dart';
import 'game/game_config.dart';
import 'game/levels.dart';
import 'screens/game_over_screen.dart';
import 'screens/game_screen.dart';
import 'screens/loader_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/schemes_screen.dart';
import 'screens/tutorial_screen.dart';
import 'theme.dart';

void main() {
  runApp(const FeatherRoadGoApp());
}

enum Screen { loader, menu, schemes, tutorial, game, gameover }

class FeatherRoadGoApp extends StatefulWidget {
  const FeatherRoadGoApp({super.key});

  @override
  State<FeatherRoadGoApp> createState() => _FeatherRoadGoAppState();
}

class _FeatherRoadGoAppState extends State<FeatherRoadGoApp> {
  Screen _screen = Screen.loader;
  int _selectedScheme = GameConfig.defaultSchemeIndex;
  int _grain = GameConfig.startingGrain;
  int _round = 0;
  GameResult? _lastResult;
  final List<int> _stars = List<int>.filled(kSchemes.length, 0);

  int get _unlockedCount {
    int unlocked = 1;
    for (int i = 0; i < _stars.length; i++) {
      if (_stars[i] > 0 && unlocked < kSchemes.length) unlocked = i + 2;
    }
    return unlocked > kSchemes.length ? kSchemes.length : unlocked;
  }

  void _go(Screen next) => setState(() => _screen = next);

  void _beginRound(int schemeIndex) {
    setState(() {
      _selectedScheme = schemeIndex;
      _round++;
      _screen = Screen.game;
    });
  }

  void _onFinish(GameResult result) {
    setState(() {
      _lastResult = result;
      _grain += result.grainReward;
      if (result.stars > _stars[result.schemeIndex]) {
        _stars[result.schemeIndex] = result.stars;
      }
      _screen = Screen.gameover;
    });
  }

  void _playAgain() {
    final GameResult? r = _lastResult;
    if (r == null) {
      _beginRound(_selectedScheme);
      return;
    }
    final int next = r.win
        ? (r.schemeIndex + 1 < kSchemes.length
            ? r.schemeIndex + 1
            : r.schemeIndex)
        : r.schemeIndex;
    _beginRound(next);
  }

  Widget _buildScreen() {
    switch (_screen) {
      case Screen.loader:
        return LoaderScreen(
          key: const ValueKey<String>('loader'),
          onDone: () => _go(Screen.menu),
        );
      case Screen.menu:
        return MenuScreen(
          key: const ValueKey<String>('menu'),
          grain: _grain,
          selectedScheme: _selectedScheme,
          onSelectScheme: (int i) => setState(() => _selectedScheme = i),
          onPlay: () => _beginRound(_selectedScheme),
          onSchemes: () => _go(Screen.schemes),
          onTutorial: () => _go(Screen.tutorial),
        );
      case Screen.schemes:
        return SchemesScreen(
          key: const ValueKey<String>('schemes'),
          stars: _stars,
          unlockedCount: _unlockedCount,
          onSelect: _beginRound,
          onBack: () => _go(Screen.menu),
        );
      case Screen.tutorial:
        return TutorialScreen(
          key: const ValueKey<String>('tutorial'),
          onBack: () => _go(Screen.menu),
          onBegin: () => _beginRound(_selectedScheme),
        );
      case Screen.game:
        return GameScreen(
          key: ValueKey<String>('game-$_round'),
          schemeIndex: _selectedScheme,
          onFinish: _onFinish,
          onBack: () => _go(Screen.menu),
        );
      case Screen.gameover:
        final GameResult result = _lastResult ??
            GameResult(
              win: false,
              stars: 0,
              schemeIndex: _selectedScheme,
              pairsDone: 0,
              pairsTotal: kSchemes[_selectedScheme].pairs,
              movesLeft: 0,
              rows: kSchemes[_selectedScheme].rows,
              cols: kSchemes[_selectedScheme].cols,
              solvedRoutes: const <List<int>>[],
            );
        return GameOverScreen(
          key: const ValueKey<String>('gameover'),
          result: result,
          bestStars: _stars[result.schemeIndex],
          onPlayAgain: _playAgain,
          onMenu: () => _go(Screen.menu),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feather Road Go',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> anim) {
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(anim),
              child: child,
            ),
          );
        },
        child: _buildScreen(),
      ),
    );
  }
}
