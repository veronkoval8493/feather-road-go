/// Tunables that the QA pipeline depends on. Do not lower loaderDurationMs.
class GameConfig {
  const GameConfig._();

  /// Splash duration, driven by a wall-clock Timer (never by an
  /// AnimationController completion listener: animator_duration_scale is 0
  /// on the CI emulator and would collapse the splash to zero).
  static const int loaderDurationMs = 8000;

  /// Fired once when the board mounts, never re-armed on input. Longer than the
  /// capture agent's first-screenshot latency so the board reaches a frame
  /// before the run resolves itself.
  static const int idleBackstopMs = 40000;

  /// The resolved board is held on screen after the final check so the result
  /// card never collapses into the action frame.
  static const int resultHoldMs = 4500;

  /// Shorter hold for the passive backstop: the board has been on screen for
  /// idleBackstopMs already.
  static const int backstopHoldMs = 800;

  static const int checkAnimMs = 420;
  static const int maxChecks = 3;
  static const int startingGrain = 120;
  static const int defaultSchemeIndex = 0;
}
