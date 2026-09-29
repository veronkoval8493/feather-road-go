import 'package:flutter/material.dart';

import '../game/board_logic.dart';
import '../game/levels.dart';
import '../theme.dart';
import '../widgets/scheme_card.dart';
import '../widgets/screen_header.dart';

/// Scheme picker. Tapping an unlocked card goes straight to the board.
class SchemesScreen extends StatefulWidget {
  final List<int> stars;
  final int unlockedCount;
  final ValueChanged<int> onSelect;
  final VoidCallback onBack;

  const SchemesScreen({
    super.key,
    required this.stars,
    required this.unlockedCount,
    required this.onSelect,
    required this.onBack,
  });

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  late final List<List<List<int>>> _previews;

  @override
  void initState() {
    super.initState();
    _previews = kSchemes
        .map((SchemeModel s) =>
            completedRoutes(buildBoard(s).solvedCopy()).values.toList())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    int collected = 0;
    for (final int s in widget.stars) {
      collected += s;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.7, -0.8),
            radius: 1.2,
            colors: <Color>[Color(0xFFF7E9C4), Color(0xFFF2EAD8)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              ScreenHeader(
                title: 'CHOOSE A SCHEME',
                onBack: widget.onBack,
                onDark: false,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$collected/${kSchemes.length * 3}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.92,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  children: <Widget>[
                    for (int i = 0; i < kSchemes.length; i++)
                      SchemeCard(
                        scheme: kSchemes[i],
                        previewRoutes: _previews[i],
                        stars: widget.stars[i],
                        locked: i >= widget.unlockedCount,
                        difficulty: 1 + (i ~/ 2),
                        onTap: () => widget.onSelect(i),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
