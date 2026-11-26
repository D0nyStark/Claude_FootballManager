import 'dart:convert';
import 'dart:io' show ZLibCodec;

import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/data/backup/raw_deflate.dart';

/// 웹에서도 도는 순수 Dart 압축이 예전 dart:io 압축과 서로 읽히는지 (백업·초대 링크 호환).
void main() {
  final text = jsonEncode({
    'g': ['id', '수요풋살', '⚽'],
    'p': [for (var i = 0; i < 40; i++) '선수$i:${'35243314'.substring(i % 8)}'],
  });

  test('예전 앱(dart:io)이 만든 데이터를 읽는다', () {
    final old = ZLibCodec(raw: true, level: 9).encode(utf8.encode(text));
    expect(utf8.decode(inflateRaw(old)), text);
  });

  test('새로 만든 데이터를 예전 앱(dart:io)이 읽는다', () {
    final now = deflateRaw(utf8.encode(text));
    expect(utf8.decode(ZLibCodec(raw: true).decode(now)), text);
  });
}
