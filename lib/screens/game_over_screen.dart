import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/board_logic.dart';
import '../theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/painters.dart';
import '../widgets/stat_pill.dart';

/// Result card. Titles are exactly YOU WON! / NO LUCK! so the capture pipeline
/// can classify the frame.
class GameOverScreen extends StatelessWidget {
  final GameResult result;
  final int bestStars;
  final VoidCallback onPlayAgain;
  final VoidCallback onMenu;

  const GameOverScreen({
    super.key,
    required this.result,
    required this.bestStars,
    required this.onPlayAgain,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final bool win = result.win;
    final Color accent = win ? AppColors.gold : AppColors.orange;

    return AppScaffold(
      background: const AssetImage(AppAssets.bgMenu),
      overlay: <Color>[
        AppColors.deep.withValues(alpha: win ? 0.82 : 0.88),
        AppColors.deepDark.withValues(alpha: win ? 0.9 : 0.94),
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 44, 20, 22),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) => Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: c.maxWidth,
                      child: _card(accent, win),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'PLAY AGAIN',
                icon: Icons.replay,
                gradient: const <Color>[AppColors.gold, AppColors.goldDeep],
                onTap: onPlayAgain,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SecondaryButton(
                  label: 'MENU',
                  icon: Icons.home,
                  onTap: onMenu,
                  onDark: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(Color accent, bool win) {
    return ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: accent, width: 2),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.deep.withValues(alpha: 0.53),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Stack(
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          AppAssets.spriteStar,
                          width: 56,
                          height: 56,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          win ? 'YOU WON!' : 'NO LUCK!',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: win ? AppColors.textPrimary : accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        StarRow(earned: result.stars, size: 40, animated: true),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CustomPaint(
                            painter: MiniBoardPainter(
                              rows: result.rows,
                              cols: result.cols,
                              routes: result.solvedRoutes,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        StatPillRow(
                          pills: <StatPill>[
                            StatPill(
                              value:
                                  '${result.pairsDone}/${result.pairsTotal}',
                              label: 'PAIRS',
                              accent: AppColors.green,
                            ),
                            StatPill(
                              value: '${result.movesLeft}',
                              label: 'MOVES LEFT',
                              accent: AppColors.gold,
                            ),
                            StatPill(
                              value: '$bestStars★',
                              label: 'BEST',
                              accent: AppColors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Image.asset(
                        AppAssets.spriteChicken,
                        width: 96,
                        height: 96,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            );
  }
}
