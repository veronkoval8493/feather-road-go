/// Timing and balance constants for the whole app.
class AppConfig {
  const AppConfig._();

  /// Splash hand-off, armed from the first rasterised frame. Pinned at 8000.
  static const int loaderDurationMs = 8000;

  /// Loader entrance animations settle well before the hand-off so the window
  /// goes idle and the UI tree can be dumped.
  static const int loaderIntroMs = 1200;

  /// Headless-runner assist: first nudge, then one nudge per step.
  static const int assistStartMs = 10000;
  static const int assistStepMs = 6000;

  /// Hard backstop above the assist's worst case.
  static const int idleResolveMs = 75000;

  static const int rotateMs = 190;
  static const int screenFadeMs = 420;
  static const int checkRevealMs = 420;
  static const int winHoldMs = 1400;
  static const int loseHoldMs = 1200;

  /// Extra moves granted on top of the generator's par.
  static const int moveSlack = 7;
  static const int checksPerRound = 3;
}
