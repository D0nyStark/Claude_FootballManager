import 'dart:typed_data';

import 'package:archive/archive.dart';

/// 순수 Dart raw DEFLATE (zlib 헤더 없음). `dart:io`의 `ZLibCodec(raw: true)`와
/// 호환되는 형식이라 예전 백업·초대 링크도 그대로 읽힌다. 웹에서도 동작.
Uint8List deflateRaw(List<int> data) => Deflate(data, level: 9).getBytes();

Uint8List inflateRaw(List<int> data) => Inflate(data).getBytes();
