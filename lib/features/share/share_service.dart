import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// 공유 시트·클립보드 (테스트에서는 가짜로 바꾼다).
class ShareService {
  const ShareService();

  Future<void> copyText(String text) =>
      Clipboard.setData(ClipboardData(text: text));

  Future<void> shareText(String text) =>
      SharePlus.instance.share(ShareParams(text: text));

  Future<void> shareImage(Uint8List png, {String? text}) =>
      SharePlus.instance.share(
        ShareParams(
          text: text,
          files: [
            XFile.fromData(png, mimeType: 'image/png', name: 'lineup.png'),
          ],
          fileNameOverrides: const ['lineup.png'],
        ),
      );

  Future<void> shareFile(Uint8List bytes, String fileName) =>
      SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'application/octet-stream',
              name: fileName,
            ),
          ],
          fileNameOverrides: [fileName],
        ),
      );
}

final shareServiceProvider = Provider<ShareService>(
  (ref) => const ShareService(),
);
