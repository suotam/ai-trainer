/// Schematické ilustrace cviků (C54 §2): archetyp pohybu = topologie postavy
/// (pojmenované body + segmenty + hlava) + 2–4 klíčové polohy v
/// normalizovaném prostoru 0..1 (y dolů) + smyčka. Interpolace je čistá
/// deterministická funkce času (EXI-002); vykreslení vlastní prezentace.
library;

import 'dart:ui' show Offset;

/// Rekvizity pozadí (podlaha, hrazda, kruhy, stěna, lavice, bedna).
enum PoseProp { floor, bar, rings, wall, bench, box, roller }

/// Způsob smyčky: tam-a-zpět (většina cviků) nebo dokola (běh, kolo).
enum PoseLoop { pingPong, cycle }

/// Topologie postavy: názvy bodů (index = pozice ve snímku), segmenty
/// (dvojice indexů) a index bodu hlavy (kruh).
class PoseTopology {
  const PoseTopology({
    required this.points,
    required this.segments,
    required this.head,
  });

  final List<String> points;
  final List<(int, int)> segments;
  final int head;
}

/// Boční pohled: hlava, krk, kyčel, koleno, chodidlo, loket, ruka.
const PoseTopology sideTopology = PoseTopology(
  points: ['head', 'neck', 'hip', 'knee', 'foot', 'elbow', 'hand'],
  segments: [(1, 2), (2, 3), (3, 4), (1, 5), (5, 6)],
  head: 0,
);

/// Čelní pohled: hlava, krk, kyčel, L/P koleno, L/P chodidlo, L/P loket,
/// L/P ruka.
const PoseTopology frontTopology = PoseTopology(
  points: [
    'head',
    'neck',
    'hip',
    'lKnee',
    'lFoot',
    'rKnee',
    'rFoot',
    'lElbow',
    'lHand',
    'rElbow',
    'rHand',
  ],
  segments: [
    (1, 2),
    (2, 3),
    (3, 4),
    (2, 5),
    (5, 6),
    (1, 7),
    (7, 8),
    (1, 9),
    (9, 10),
  ],
  head: 0,
);

/// Jen předloktí (zápěstí/prsty): loket, zápěstí, konečky prstů.
const PoseTopology forearmTopology = PoseTopology(
  points: ['elbow', 'wrist', 'fingers'],
  segments: [(0, 1), (1, 2)],
  head: -1,
);

/// Archetyp pohybu (C54 §2). [frames] = klíčové polohy (každá stejně
/// dlouhá jako `topology.points`), [cycle] = doba jednoho průchodu.
class ExercisePoseAnimation {
  const ExercisePoseAnimation({
    required this.topology,
    required this.frames,
    this.props = const [],
    this.loop = PoseLoop.pingPong,
    this.cycle = const Duration(milliseconds: 1600),
  });

  final PoseTopology topology;
  final List<List<Offset>> frames;
  final List<PoseProp> props;
  final PoseLoop loop;
  final Duration cycle;

  bool get isValid =>
      frames.isNotEmpty &&
      frames.every((f) => f.length == topology.points.length);
}

/// Poloha v čase [t] (0..1 v rámci cyklu) — deterministická interpolace
/// (EXI-002): pingPong jde po snímcích tam a zpět, cycle dokola.
List<Offset> poseAt(ExercisePoseAnimation animation, double t) {
  final frames = animation.frames;
  if (frames.length == 1) {
    return frames.first;
  }
  final phase = (t % 1.0 + 1.0) % 1.0;
  final int segments;
  final double position;
  if (animation.loop == PoseLoop.cycle) {
    segments = frames.length;
    position = phase * segments;
  } else {
    segments = (frames.length - 1) * 2;
    position = phase * segments;
  }
  var index = position.floor();
  final local = position - index;
  if (index >= segments) {
    index = segments - 1;
  }
  int from;
  int to;
  if (animation.loop == PoseLoop.cycle) {
    from = index % frames.length;
    to = (index + 1) % frames.length;
  } else {
    final forward = index < frames.length - 1;
    from = forward ? index : segments - index;
    to = forward ? index + 1 : segments - index - 1;
  }
  final eased = _easeInOut(local);
  final a = frames[from];
  final b = frames[to];
  return [
    for (var i = 0; i < a.length; i++)
      Offset(
        a[i].dx + (b[i].dx - a[i].dx) * eased,
        a[i].dy + (b[i].dy - a[i].dy) * eased,
      ),
  ];
}

double _easeInOut(double x) =>
    x < 0.5 ? 2 * x * x : 1 - (-2 * x + 2) * (-2 * x + 2) / 2;
