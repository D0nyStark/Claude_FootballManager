import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/backup/group_bundle.dart';
import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../share/share_service.dart';

final bundleServiceProvider = Provider(
  (ref) =>
      BundleService(ref.watch(databaseProvider), ref.watch(deviceIdProvider)),
);

/// 백업 파일 고르기 → 파일 내용(문자열). 테스트에서는 가짜로 바꾼다.
final pickBackupFileProvider = Provider<Future<String?> Function()>(
  (ref) => () async {
    final files = await FilePicker.pickFiles();
    if (files.isEmpty) return null;
    final bytes = await files.first.readAsBytes();
    return utf8.decode(bytes, allowMalformed: true);
  },
);

/// 가져오기 직전 자동 백업을 둘 폴더.
final autoBackupDirProvider = Provider<Future<Directory> Function()>(
  (ref) => () async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/backups').create(recursive: true);
  },
);

String _stamp(DateTime d) =>
    '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}'
    '_${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}';

/// 모임 백업 내보내기 (SPEC F9): .mug 파일을 공유 시트로 (카톡·드라이브·파일).
Future<void> exportGroupBackup(WidgetRef ref, GroupInfo group) async {
  final bundle = await ref.read(bundleServiceProvider).export(group.id);
  final name = group.name.replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '_');
  await ref
      .read(shareServiceProvider)
      .shareFile(
        utf8.encode(bundle.encode()),
        '${name}_${_stamp(DateTime.now())}.mug',
      );
}

/// 모임 백업 가져오기 (SPEC F9): 미리보기 → 덮어쓰기/병합 → 가져오기 직전 자동 백업.
Future<void> importGroupBackup(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final text = await ref.read(pickBackupFileProvider)();
  if (text == null) return;
  final GroupBundle bundle;
  try {
    bundle = GroupBundle.decode(text);
  } on Object {
    messenger.showSnackBar(
      const SnackBar(content: Text('풋살 팀메이커 백업 파일이 아니에요.')),
    );
    return;
  }
  final service = ref.read(bundleServiceProvider);
  final exists = await service.groupExists(bundle.groupId);
  if (!context.mounted) return;
  final mode = await showDialog<ImportMode>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('"${bundle.groupName}" 백업'),
      content: Text(
        '${bundle.exportedAt.month}/${bundle.exportedAt.day}에 내보낸 백업이에요.\n'
        '선수 ${bundle.playerCount}명 · 조건 ${bundle.constraintCount}개 · '
        '편성 이력 ${bundle.lineupCount}개\n\n'
        '${exists ? '이 기기에 같은 모임이 있어요.\n'
                  '병합: 항목별로 더 최근에 고친 쪽을 남겨요.\n'
                  '덮어쓰기: 이 기기의 모임 내용을 백업 내용으로 바꿔요.\n'
                  '${kIsWeb ? '(웹에서는 자동 백업이 없어요. 덮어쓰기 전에 [백업 내보내기]를 먼저 해 두세요)' : '(가져오기 전에 지금 상태를 자동으로 백업해 둬요)'}' : '새 모임으로 추가돼요.'}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        if (exists) ...[
          TextButton(
            key: const Key('importOverwrite'),
            onPressed: () => Navigator.pop(context, ImportMode.overwrite),
            child: const Text('덮어쓰기'),
          ),
          FilledButton(
            key: const Key('importMerge'),
            onPressed: () => Navigator.pop(context, ImportMode.merge),
            child: const Text('병합'),
          ),
        ] else
          FilledButton(
            key: const Key('importNew'),
            onPressed: () => Navigator.pop(context, ImportMode.merge),
            child: const Text('가져오기'),
          ),
      ],
    ),
  );
  if (mode == null) return;

  // 웹에는 파일 폴더가 없어 자동 백업을 건너뛴다 (가져오기 창에서 미리 내보내기를 권함).
  if (exists && !kIsWeb) {
    // 가져오기 직전 자동 백업 (실패해도 가져오기는 진행).
    try {
      final dir = await ref.read(autoBackupDirProvider)();
      final current = await service.export(bundle.groupId);
      await File('${dir.path}/${bundle.groupId}_${_stamp(DateTime.now())}.mug')
          .writeAsString(current.encode());
    } on Object {
      // 무시
    }
  }
  final summary = await service.import(bundle, mode: mode);
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        summary.createdGroup
            ? '"${bundle.groupName}" 모임을 가져왔어요.'
            : '가져왔어요 · $summary',
      ),
    ),
  );
}
