import 'dart:convert';
import 'dart:typed_data';

import '../../core/models/player_stats.dart';
import 'raw_deflate.dart';
import 'group_bundle.dart';

/// 초대 링크용 짧은 형식 (SPEC F13, §7.2) — "MUG2:" + base64url(deflate(압축 JSON)).
///
/// 백업 파일(MUG1)과 같은 [GroupBundle]을 담지만 링크에 넣을 수 있게 줄인다:
/// - 항목 이름 대신 위치로 구분하는 배열
/// - uuid(36자) → 16바이트 base64url(22자)
/// - 시각은 묶음 생성 시각과의 차이(초)
/// - 제약·편성 이력의 선수 참조는 선수 목록의 번호
/// - [includeStats]가 false면 능력치를 빼고, 받는 쪽은 자기 능력치를 그대로 둔다 (멤버가 보낸 변경 공유)
abstract final class InviteCodec {
  static const String prefix = 'MUG2:';

  /// 이보다 길면 링크 대신 .mug 파일로 공유한다 (SPEC F13.1).
  static const int maxLinkLength = 4000;

  static const _stats = [
    'shooting',
    'dribbling',
    'speed',
    'passing',
    'physical',
    'creativity',
    'teamwork',
    // 체력은 뒤에 붙인다: 예전 7자리 링크(1.0.2 이전)도 앞 7자리는 그대로 읽힌다.
    'stamina',
  ];
  static const _positions = ['fixo', 'ala', 'pivo'];
  static const _slots = ['gk', 'fixo1', 'fixo2', 'alaLeft', 'alaRight', 'pivo'];

  // ───────────────────────── 인코딩 ─────────────────────────

  static String encode(GroupBundle b, {bool includeStats = true}) {
    final atMs = b.exportedAt.millisecondsSinceEpoch;
    int dt(Object? ms) =>
        ms == null ? 0 : ((atMs - (ms as int)) / 1000).round();
    final ids = <String, int>{};
    for (final p in b.players) {
      ids[p['id'] as String] = ids.length;
    }
    final g = b.group;
    final json = {
      'v': 2,
      'at': atMs ~/ 1000,
      'f': _short(b.from),
      if (b.role != null) 'r': b.role,
      's': includeStats ? 1 : 0,
      'g': [
        _short(g['id'] as String),
        g['name'],
        g['icon'],
        g['color'],
        g['defaultFormat'],
      ],
      'p': [
        for (final p in b.players)
          [
            _short(p['id'] as String),
            p['name'],
            p['nickname'] ?? 0,
            p['memberType'] == 'core' ? 1 : 0,
            if (includeStats) [for (final s in _stats) p[s]].join() else 0,
            _positions.indexOf(p['mainPosition'] as String),
            _subMask(p['subPositions'] as String? ?? ''),
            (p['canKeep'] == true ? 1 : 0) |
                (p['isGuest'] == true ? 2 : 0) |
                (p['statsSimple'] == true ? 4 : 0),
            p['memo'] ?? 0,
            dt(p['createdAt']),
            dt(p['updatedAt']),
            p['deletedAt'] == null ? -1 : dt(p['deletedAt']),
          ],
      ],
      'c': [
        for (final c in b.constraints)
          [
            _short(c['id'] as String),
            c['type'] == 'apart' ? 1 : 0,
            [
              for (final id in (c['playerIds'] as String).split(','))
                ids[id] ?? _short(id),
            ],
            c['note'] ?? 0,
            dt(c['updatedAt']),
            c['deletedAt'] == null ? -1 : dt(c['deletedAt']),
          ],
      ],
      'h': [for (final h in b.lineups) _encodeLineup(h, ids, dt)],
      'st': [
        for (final s in b.settings) [s['key'], s['value'], dt(s['updatedAt'])],
      ],
    };
    final bytes = deflateRaw(utf8.encode(jsonEncode(json)));
    return '$prefix${base64Url.encode(bytes).replaceAll('=', '')}';
  }

  static List<Object?> _encodeLineup(
    Map<String, Object?> h,
    Map<String, int> ids,
    int Function(Object?) dt,
  ) {
    final body = (jsonDecode(h['json'] as String) as Map)
        .cast<String, Object?>();
    final names = (body['names'] as Map).cast<String, String>();
    Object ref(String id) => ids[id] ?? _short(id);
    final guests = {
      for (final e in names.entries)
        if (!ids.containsKey(e.key)) _short(e.key): e.value,
    };
    return [
      _short(h['id'] as String),
      dt(h['confirmedAt']),
      ((h['balanceScore'] as num) * 10).round(),
      body['format'],
      body['keeperMode'],
      [
        for (final t in (body['teams'] as List).cast<Map>())
          [
            t['name'],
            t['color'],
            {
              for (final e in (t['slots'] as Map).entries)
                '${_slots.indexOf(e.key as String)}': ref(e.value as String),
            },
            [for (final id in (t['bench'] as List).cast<String>()) ref(id)],
            t['keeper'] == null ? -1 : ref(t['keeper'] as String),
          ],
      ],
      guests,
      dt(h['updatedAt']),
      h['deletedAt'] == null ? -1 : dt(h['deletedAt']),
    ];
  }

  // ───────────────────────── 디코딩 ─────────────────────────

  /// 텍스트 안의 초대 링크(MUG2) 또는 백업(MUG1)을 찾아 묶음으로 바꾼다. 없으면 null.
  static GroupBundle? tryParse(String text) {
    // 앱 주소(futsalteammaker://join?d=…)로 들어오면 ':'가 %3A로 바뀌어 있을 수 있다.
    if (text.contains('%3A')) {
      try {
        text = Uri.decodeComponent(text);
      } on Object {
        // 그대로 시도
      }
    }
    try {
      if (text.contains(prefix)) return decode(text);
      if (text.contains(GroupBundle.prefix)) return GroupBundle.decode(text);
    } on Object {
      return null;
    }
    return null;
  }

  static GroupBundle decode(String text) {
    var s = text.substring(text.indexOf(prefix) + prefix.length);
    s = s.split(RegExp(r'[^A-Za-z0-9_\-]')).first;
    final padded = s.padRight((s.length + 3) ~/ 4 * 4, '=');
    final j = jsonDecode(
      utf8.decode(inflateRaw(base64Url.decode(padded))),
    ) as Map<String, Object?>;
    if (j['v'] != 2) throw const FormatException('지원하지 않는 초대 링크 버전');

    final atMs = (j['at'] as int) * 1000;
    int ms(int dt) => atMs - dt * 1000;
    int? deleted(int dt) => dt < 0 ? null : ms(dt);
    final withStats = j['s'] == 1;
    final playerRows = (j['p'] as List).cast<List>();
    final playerIds = [for (final p in playerRows) _long(p[0] as String)];
    String ref(Object r) => r is int ? playerIds[r] : _long(r as String);
    final from = _long(j['f'] as String);
    final g = (j['g'] as List);

    return GroupBundle(
      group: {
        'id': _long(g[0] as String),
        'name': g[1],
        'icon': g[2],
        'color': g[3],
        'defaultFormat': g[4],
      },
      players: [
        for (final (i, p) in playerRows.indexed)
          {
            'id': playerIds[i],
            'name': p[1],
            'nickname': p[2] == 0 ? null : p[2],
            'memberType': p[3] == 1 ? 'core' : 'regular',
            if (withStats && p[4] is String) ..._decodeStats(p[4] as String),
            'mainPosition': _positions[p[5] as int],
            'subPositions': [
              for (final (k, pos) in _positions.indexed)
                if ((p[6] as int) & (1 << k) != 0) pos,
            ].join(','),
            'canKeep': (p[7] as int) & 1 != 0,
            'isGuest': (p[7] as int) & 2 != 0,
            'statsSimple': (p[7] as int) & 4 != 0,
            'memo': p[8] == 0 ? null : p[8],
            'createdAt': ms(p[9] as int),
            'updatedAt': ms(p[10] as int),
            'updatedBy': from,
            'deletedAt': deleted(p[11] as int),
          },
      ],
      constraints: [
        for (final c in (j['c'] as List).cast<List>())
          {
            'id': _long(c[0] as String),
            'type': c[1] == 1 ? 'apart' : 'together',
            'playerIds': [for (final r in c[2] as List) ref(r as Object)]
                .join(','),
            'note': c[3] == 0 ? null : c[3],
            'updatedAt': ms(c[4] as int),
            'updatedBy': from,
            'deletedAt': deleted(c[5] as int),
          },
      ],
      lineups: [
        for (final h in (j['h'] as List).cast<List>())
          _decodeLineup(h, ref, ms, deleted, from, playerIds, playerRows),
      ],
      settings: [
        for (final s in (j['st'] as List).cast<List>())
          {'key': s[0], 'value': s[1], 'updatedAt': ms(s[2] as int)},
      ],
      exportedAt: DateTime.fromMillisecondsSinceEpoch(atMs),
      from: from,
      role: j['r'] as String?,
    );
  }

  static Map<String, Object?> _decodeLineup(
    List h,
    String Function(Object) ref,
    int Function(int) ms,
    int? Function(int) deleted,
    String from,
    List<String> playerIds,
    List<List> playerRows,
  ) {
    final teams = (h[5] as List).cast<List>();
    final names = <String, String>{
      for (final (i, id) in playerIds.indexed) id: playerRows[i][1] as String,
      for (final e in (h[6] as Map).entries)
        _long(e.key as String): e.value as String,
    };
    final decodedTeams = [
      for (final t in teams)
        {
          'name': t[0],
          'color': t[1],
          'slots': {
            for (final e in (t[2] as Map).entries)
              _slots[int.parse(e.key as String)]: ref(e.value as Object),
          },
          'bench': [for (final r in t[3] as List) ref(r as Object)],
          'keeper': t[4] == -1 ? null : ref(t[4] as Object),
        },
    ];
    final used = {
      for (final t in decodedTeams) ...[
        ...(t['slots'] as Map<String, String>).values,
        ...t['bench'] as List<String>,
      ],
    };
    final body = {
      'v': 1,
      'format': h[3],
      'keeperMode': h[4],
      'teams': decodedTeams,
      'names': {
        for (final e in names.entries)
          if (used.contains(e.key)) e.key: e.value,
      },
    };
    return {
      'id': _long(h[0] as String),
      'confirmedAt': ms(h[1] as int),
      'balanceScore': (h[2] as int) / 10,
      'json': jsonEncode(body),
      'updatedAt': ms(h[7] as int),
      'updatedBy': from,
      'deletedAt': deleted(h[8] as int),
    };
  }

  /// "33333333" → 능력치. 7자리(체력 없음)는 체력을 나머지 평균으로 채운다.
  static Map<String, int> _decodeStats(String digits) {
    final values = [for (final c in digits.split('')) int.parse(c)];
    final map = {
      for (var k = 0; k < values.length && k < _stats.length; k++)
        _stats[k]: values[k],
    };
    map['stamina'] ??= PlayerStats.legacyStamina(values.take(7));
    return map;
  }

  // ───────────────────────── uuid 줄이기 ─────────────────────────

  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );

  /// uuid는 22자 base64url로, 그 밖의 id는 "~" + 원래 값.
  static String _short(String id) {
    if (!_uuid.hasMatch(id)) return '~$id';
    final hex = id.replaceAll('-', '');
    final bytes = Uint8List.fromList([
      for (var i = 0; i < 32; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ]);
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static String _long(String s) {
    if (s.startsWith('~')) return s.substring(1);
    final bytes = base64Url.decode('$s==');
    final hex = [for (final b in bytes) b.toRadixString(16).padLeft(2, '0')]
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  static int _subMask(String subs) {
    var mask = 0;
    for (final s in subs.split(',')) {
      final i = _positions.indexOf(s);
      if (i >= 0) mask |= 1 << i;
    }
    return mask;
  }
}
