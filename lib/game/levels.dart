/// One puzzle scheme. Routes are carved from row/column bands, so every scheme
/// is solvable by construction — there is no generate-then-reject loop.
class SchemeModel {
  final String name;
  final int rows;
  final int cols;

  /// Band sizes; the sum equals [rows] (or [cols] when [vertical] is true).
  /// Each band becomes exactly one grain-sack to feeder route.
  final List<int> bands;

  /// Bands run down the columns instead of across the rows.
  final bool vertical;

  /// Flips the serpentine start direction of every band.
  final bool flip;

  /// Extra moves granted on top of the exact minimum.
  final int slack;

  final int seed;

  const SchemeModel({
    required this.name,
    required this.rows,
    required this.cols,
    required this.bands,
    required this.vertical,
    required this.flip,
    required this.slack,
    required this.seed,
  });

  int get pairs => bands.length;

  String get sizeLabel => '$rows' '×' '$cols';
}

const List<SchemeModel> kSchemes = <SchemeModel>[
  SchemeModel(
    name: 'MEADOW',
    rows: 5,
    cols: 5,
    bands: <int>[2, 3],
    vertical: false,
    flip: false,
    slack: 5,
    seed: 11,
  ),
  SchemeModel(
    name: 'ORCHARD',
    rows: 5,
    cols: 5,
    bands: <int>[3, 2],
    vertical: true,
    flip: true,
    slack: 5,
    seed: 23,
  ),
  SchemeModel(
    name: 'FARM',
    rows: 6,
    cols: 6,
    bands: <int>[2, 2, 2],
    vertical: false,
    flip: true,
    slack: 4,
    seed: 37,
  ),
  SchemeModel(
    name: 'PASTURE',
    rows: 6,
    cols: 6,
    bands: <int>[2, 2, 2],
    vertical: true,
    flip: false,
    slack: 4,
    seed: 41,
  ),
  SchemeModel(
    name: 'BARN',
    rows: 7,
    cols: 7,
    bands: <int>[2, 2, 2, 1],
    vertical: false,
    flip: false,
    slack: 3,
    seed: 59,
  ),
  SchemeModel(
    name: 'HARVEST',
    rows: 7,
    cols: 7,
    bands: <int>[1, 2, 2, 2],
    vertical: true,
    flip: true,
    slack: 3,
    seed: 71,
  ),
];

/// Chips shown on the menu sheet map onto these scheme indices.
const List<int> kMenuChipSchemes = <int>[0, 2, 4];
