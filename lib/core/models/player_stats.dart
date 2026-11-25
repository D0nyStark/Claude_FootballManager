/// 능력치 항목 (SPEC §4.2). 각 1~5점 정수.
enum Stat {
  shooting('슈팅'),
  dribbling('드리블'),
  speed('스피드'),
  passing('패스'),
  physical('피지컬'),
  creativity('창의력'),

  /// 수비 가담 + 협력.
  teamwork('협력');

  const Stat(this.label);

  final String label;
}

/// 선수 한 명의 7개 능력치.
class PlayerStats {
  PlayerStats({
    required int shooting,
    required int dribbling,
    required int speed,
    required int passing,
    required int physical,
    required int creativity,
    required int teamwork,
  }) : _values = List.unmodifiable([
         _check(shooting),
         _check(dribbling),
         _check(speed),
         _check(passing),
         _check(physical),
         _check(creativity),
         _check(teamwork),
       ]);

  /// 빠른 입력: 7개 항목을 모두 같은 값으로 채운다.
  PlayerStats.uniform(int value)
    : _values = List.unmodifiable(
        List.filled(Stat.values.length, _check(value)),
      );

  /// [Stat] 순서대로 값을 받는다.
  PlayerStats.fromMap(Map<Stat, int> values)
    : _values = List.unmodifiable([
        for (final s in Stat.values) _check(values[s] ?? defaultValue),
      ]);

  static const int minValue = 1;
  static const int maxValue = 5;
  static const int defaultValue = 3;

  final List<int> _values;

  int operator [](Stat stat) => _values[stat.index];

  /// 종합 능력치 OVR = 7개 항목 평균 (1.0~5.0).
  double get ovr => _values.reduce((a, b) => a + b) / _values.length;

  Map<Stat, int> toMap() => {for (final s in Stat.values) s: this[s]};

  PlayerStats copyWith(Stat stat, int value) {
    final map = toMap()..[stat] = value;
    return PlayerStats.fromMap(map);
  }

  static int _check(int v) {
    if (v < minValue || v > maxValue) {
      throw ArgumentError.value(v, 'stat', '능력치는 $minValue~$maxValue 사이여야 합니다');
    }
    return v;
  }

  @override
  bool operator ==(Object other) =>
      other is PlayerStats &&
      Iterable.generate(_values.length)
          .every((i) => _values[i] == other._values[i]);

  @override
  int get hashCode => Object.hashAll(_values);

  @override
  String toString() => 'PlayerStats(${_values.join(',')})';
}
