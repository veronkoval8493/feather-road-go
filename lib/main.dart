import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'game/game_config.dart';
import 'game/progress_store.dart';
import 'game/schemes.dart';
import 'panels/scheme_select_panel.dart';
import 'panels/tutorial_panel.dart';
import 'screens/game_over_screen.dart';
import 'screens/game_screen.dart';
import 'screens/loader_screen.dart';
import 'screens/menu_screen.dart';
import 'theme.dart';

/// Every destination of the app. `result` is mandatory: without it the capture
/// tooling never gathers a verdict frame.
enum Screen { loader, menu, schemes, tutorial, game, result }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Flutter only publishes a semantics tree while a client holds a handle; the
  // test emulators bind no accessibility service, so ask for one explicitly.
  SemanticsBinding.instance.ensureSemantics();
  runApp(const FeatherRoadGoApp());
}

class FeatherRoadGoApp extends StatelessWidget {
  const FeatherRoadGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feather Road Go',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  Screen _screen = Screen.loader;
  int _schemeIndex = kDefaultSchemeIndex;
  int _gameRun = 0;
  RoundResult? _lastResult;

  void _go(Screen screen) {
    setState(() => _screen = screen);
  }

  void _startScheme(int index) {
    setState(() {
      _schemeIndex = index;
      _gameRun++;
      _screen = Screen.game;
    });
  }

  void _finishRound(RoundResult result) {
    setState(() {
      _lastResult = result;
      _screen = Screen.result;
    });
  }

  /// Android Back goes one screen up and never pops out of the menu.
  void _handleBack() {
    switch (_screen) {
      case Screen.loader:
      case Screen.menu:
        break;
      case Screen.schemes:
      case Screen.tutorial:
      case Screen.game:
      case Screen.result:
        _go(Screen.menu);
    }
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
          schemeCount: kSchemes.length,
          totalStars: ProgressStore.instance.totalStars,
          onPlay: () => _startScheme(_schemeIndex),
          onSchemes: () => _go(Screen.schemes),
          onRules: () => _go(Screen.tutorial),
        );
      case Screen.schemes:
        return SchemeSelectPanel(
          key: const ValueKey<String>('schemes'),
          onBack: () => _go(Screen.menu),
          onPick: _startScheme,
        );
      case Screen.tutorial:
        return TutorialPanel(
          key: const ValueKey<String>('tutorial'),
          onBack: () => _go(Screen.menu),
        );
      case Screen.game:
        return GameScreen(
          key: ValueKey<String>('game-$_gameRun'),
          scheme: kSchemes[_schemeIndex],
          schemeIndex: _schemeIndex,
          onExit: () => _go(Screen.menu),
          onFinish: _finishRound,
        );
      case Screen.result:
        final RoundResult? result = _lastResult;
        if (result == null) {
          return MenuScreen(
            key: const ValueKey<String>('menu-fallback'),
            schemeCount: kSchemes.length,
            totalStars: ProgressStore.instance.totalStars,
            onPlay: () => _startScheme(_schemeIndex),
            onSchemes: () => _go(Screen.schemes),
            onRules: () => _go(Screen.tutorial),
          );
        }
        return GameOverScreen(
          key: ValueKey<String>('result-$_gameRun'),
          result: result,
          schemeTitle: kSchemes[result.schemeIndex].title,
          bestGrain: ProgressStore.instance.bestGrain,
          onPlayAgain: () => _startScheme(result.schemeIndex),
          onSchemes: () => _go(Screen.schemes),
          onHome: () => _go(Screen.menu),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        _handleBack();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: AppConfig.screenFadeMs),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _buildScreen(),
      ),
    );
  }
}
