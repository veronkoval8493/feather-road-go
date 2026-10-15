/// One playable board definition. Seeded, so a scheme is reproducible.
class SchemeDef {
  const SchemeDef({
    required this.number,
    required this.title,
    required this.band,
    required this.cols,
    required this.rows,
    required this.seed,
    required this.minTurns,
    required this.maxTurns,
  });

  final int number;
  final String title;
  final String band;
  final int cols;
  final int rows;
  final int seed;
  final int minTurns;
  final int maxTurns;

  String get sizeLabel => '$cols x $rows';
}

const int kDefaultSchemeIndex = 0;

const List<SchemeDef> kSchemes = <SchemeDef>[
  SchemeDef(number: 1, title: 'BARNYARD', band: 'EASY 5x5', cols: 5, rows: 5, seed: 1101, minTurns: 6, maxTurns: 7),
  SchemeDef(number: 2, title: 'HAY LANE', band: 'EASY 5x5', cols: 5, rows: 5, seed: 1207, minTurns: 6, maxTurns: 8),
  SchemeDef(number: 3, title: 'OAT GATE', band: 'EASY 5x5', cols: 5, rows: 5, seed: 1319, minTurns: 7, maxTurns: 8),
  SchemeDef(number: 4, title: 'MILL PATH', band: 'EASY 5x5', cols: 5, rows: 5, seed: 1423, minTurns: 7, maxTurns: 9),
  SchemeDef(number: 5, title: 'CLOVER ROW', band: 'FARMER 5x5', cols: 5, rows: 5, seed: 2111, minTurns: 7, maxTurns: 9),
  SchemeDef(number: 6, title: 'STRAW BEND', band: 'FARMER 5x5', cols: 5, rows: 5, seed: 2237, minTurns: 8, maxTurns: 9),
  SchemeDef(number: 7, title: 'RED FENCE', band: 'FARMER 5x5', cols: 5, rows: 5, seed: 2341, minTurns: 8, maxTurns: 9),
  SchemeDef(number: 8, title: 'DUSK COOP', band: 'FARMER 5x5', cols: 5, rows: 5, seed: 2459, minTurns: 8, maxTurns: 9),
  SchemeDef(number: 9, title: 'GRAIN MILL', band: 'MASTER 6x6', cols: 6, rows: 6, seed: 3121, minTurns: 9, maxTurns: 11),
  SchemeDef(number: 10, title: 'LONG YARD', band: 'MASTER 6x6', cols: 6, rows: 6, seed: 3253, minTurns: 10, maxTurns: 12),
  SchemeDef(number: 11, title: 'OLD BARN', band: 'MASTER 6x6', cols: 6, rows: 6, seed: 3371, minTurns: 11, maxTurns: 13),
  SchemeDef(number: 12, title: 'HARVEST', band: 'MASTER 6x6', cols: 6, rows: 6, seed: 3491, minTurns: 11, maxTurns: 13),
];

const List<String> kBands = <String>['EASY 5x5', 'FARMER 5x5', 'MASTER 6x6'];
