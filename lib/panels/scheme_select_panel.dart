import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/progress_store.dart';
import '../game/schemes.dart';
import '../theme.dart';
import '../widgets/scheme_tile.dart';

/// The farm map: twelve schemes in three difficulty bands.
class SchemeSelectPanel extends StatelessWidget {
  const SchemeSelectPanel({
    super.key,
    required this.onBack,
    required this.onPick,
  });

  final VoidCallback onBack;
  final void Function(int index) onPick;

  @override
  Widget build(BuildContext context) {
    final ProgressStore store = ProgressStore.instance;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            AppAssets.bgGame,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: AppColors.inkSoft),
          ),
          ColoredBox(color: AppColors.ink.withValues(alpha: 0.82)),
          Column(
            children: <Widget>[
              PanelHeader(title: 'FARM MAP', onBack: onBack),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  child: Column(
                    children: <Widget>[
                      for (final String band in kBands) ...<Widget>[
                        _bandCard(band, store),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bandCard(String band, ProgressStore store) {
    final List<int> indices = <int>[
      for (int i = 0; i < kSchemes.length; i++)
        if (kSchemes[i].band == band) i,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceEdge, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            band,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
              color: AppColors.goldText,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              for (final int index in indices)
                SchemeTile(
                  number: kSchemes[index].number,
                  stars: store.starsFor(index),
                  locked: !store.isUnlocked(index),
                  onTap: () => onPick(index),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shared dark header for both panels: 44px status-bar inset plus 72px bar.
class PanelHeader extends StatelessWidget {
  const PanelHeader({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 44),
      decoration: const BoxDecoration(
        color: AppColors.ink,
        border: Border(
          bottom: BorderSide(color: Color(0x59F2C64A), width: 2),
        ),
      ),
      child: SizedBox(
        height: 72,
        child: Row(
          children: <Widget>[
            const SizedBox(width: 6),
            SizedBox(
              width: 44,
              height: 44,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: onBack,
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 22,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: AppColors.surface,
                ),
              ),
            ),
            const SizedBox(width: 50),
          ],
        ),
      ),
    );
  }
}
