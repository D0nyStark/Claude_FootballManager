import 'dart:math' as math;

import 'package:futsalteammaker/core/models/models.dart';

/// 테스트용 선수 생성.
Player makePlayer(
  String id, {
  int stat = 3,
  Position position = Position.ala,
  Set<Position> sub = const {},
  bool canKeep = false,
  PlayerStats? stats,
}) => Player(
  id: id,
  name: '선수$id',
  stats: stats ?? PlayerStats.uniform(stat),
  mainPosition: position,
  subPositions: sub,
  canKeep: canKeep,
);

/// 현실적인 무작위 덱: 선수마다 기본 실력(1~5)에 항목별 ±1 편차.
List<Player> randomDeck(
  math.Random rng,
  int count, {
  double pivoRatio = -1,
  String prefix = 'p',
}) {
  int clamp(int v) => v < 1 ? 1 : (v > 5 ? 5 : v);
  return List.generate(count, (i) {
    final base = 1 + rng.nextInt(5);
    int stat() => clamp(base + rng.nextInt(3) - 1);
    final Position main;
    if (pivoRatio >= 0) {
      main = rng.nextDouble() < pivoRatio
          ? Position.pivo
          : (rng.nextBool() ? Position.fixo : Position.ala);
    } else {
      main = Position.values[rng.nextInt(Position.values.length)];
    }
    final sub = <Position>{
      if (rng.nextDouble() < 0.4) Position.values[rng.nextInt(3)],
    };
    return Player(
      id: '$prefix${i.toString().padLeft(2, '0')}',
      name: '선수$i',
      stats: PlayerStats(
        shooting: stat(),
        dribbling: stat(),
        speed: stat(),
        passing: stat(),
        physical: stat(),
        creativity: stat(),
        stamina: stat(),
        teamwork: stat(),
      ),
      mainPosition: main,
      subPositions: sub,
      canKeep: rng.nextDouble() < 0.25,
    );
  });
}
