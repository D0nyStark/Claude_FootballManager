import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../config.dart';
import '../../core/models/group_role.dart';
import '../../data/backup/group_bundle.dart';
import '../../data/backup/invite_codec.dart';
import '../../data/providers.dart';
import '../../data/repositories/device_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../backup/backup_actions.dart';
import '../share/share_service.dart';

/// 앱이 링크로 열렸을 때 들어오는 주소들 (app_links). 테스트에서는 바꾼다.
final incomingLinksProvider = Provider<Stream<String>>(
  (ref) => const Stream.empty(),
);

/// 클립보드 읽기 (설치 직후 첫 실행 때 복사된 초대 감지, SPEC F13.3).
final clipboardTextProvider = Provider<Future<String?> Function()>(
  (ref) =>
      () async => (await Clipboard.getData(Clipboard.kTextPlain))?.text,
);

/// 초대 링크 (안내 페이지 주소 + '#' + 묶음).
String inviteLink(String payload) => '${AppConfig.inviteBaseUrl}#$payload';

Future<String> _payload(WidgetRef ref, GroupInfo group, {String? role}) async {
  final bundle = await ref
      .read(bundleServiceProvider)
      .export(group.id, role: role);
  // 멤버는 능력치를 볼 수 없으므로, 멤버가 보내는 링크에는 능력치를 넣지 않는다 (SPEC F13.4).
  return InviteCodec.encode(bundle, includeStats: group.role.canSeeStats);
}

/// 모임 업데이트 링크 (확정·공유 때 함께 보내기용).
Future<String> updateLinkText(WidgetRef ref, GroupInfo group) async =>
    '📤 모임 업데이트: ${inviteLink(await _payload(ref, group))}';

/// 초대하기 (SPEC F13.1): 역할을 고르고 카카오톡·메시지로 링크 전송.
Future<void> sendInvite(
  BuildContext context,
  WidgetRef ref,
  GroupInfo group,
) async {
  final role = await showDialog<GroupRole>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text('"${group.name}" 초대하기'),
      children: [
        SimpleDialogOption(
          key: const Key('inviteManager'),
          onPressed: group.role.canSeeStats
              ? () => Navigator.pop(context, GroupRole.manager)
              : null,
          child: ListTile(
            enabled: group.role.canSeeStats,
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('운영진으로 초대'),
            subtitle: const Text('능력치까지 보고 고칠 수 있어요'),
          ),
        ),
        SimpleDialogOption(
          key: const Key('inviteMember'),
          onPressed: () => Navigator.pop(context, GroupRole.member),
          child: const ListTile(
            leading: Icon(Icons.person),
            title: Text('멤버로 초대'),
            subtitle: Text('팀 짜기·선수 관리는 되고, 능력치는 보이지 않아요'),
          ),
        ),
      ],
    ),
  );
  if (role == null || !context.mounted) return;
  await _sendLink(
    context,
    ref,
    group,
    role: role.name,
    message: (link) =>
        '⚽ [${group.name}] 모임에 초대합니다! (${role.label})\n'
        "아래 링크를 눌러 '풋살 팀메이커'에서 열어주세요.\n$link",
  );
}

/// 변경 공유 (SPEC F13.4): 최신 모임 데이터를 링크로 다시 보낸다.
Future<void> shareChanges(
  BuildContext context,
  WidgetRef ref,
  GroupInfo group,
) => _sendLink(
  context,
  ref,
  group,
  message: (link) =>
      '📤 [${group.name}] 모임 변경 사항이에요.\n'
      "링크를 누르면 '풋살 팀메이커'에 반영돼요.\n$link",
);

Future<void> _sendLink(
  BuildContext context,
  WidgetRef ref,
  GroupInfo group, {
  String? role,
  required String Function(String link) message,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final share = ref.read(shareServiceProvider);
  final payload = await _payload(ref, group, role: role);
  if (payload.length > InviteCodec.maxLinkLength) {
    // 너무 길면 .mug 파일로 (받는 사람은 파일을 열어 가져오기).
    final bundle = await ref
        .read(bundleServiceProvider)
        .export(group.id, role: role);
    await share.shareFile(utf8.encode(bundle.encode()), '${group.name}_초대.mug');
    messenger.showSnackBar(
      const SnackBar(
        content: Text('데이터가 커서 파일로 보냈어요. 받은 사람은 파일을 열어 가져오기 하세요.'),
      ),
    );
  } else {
    await share.shareText(message(inviteLink(payload)));
  }
  await ref.read(groupRepositoryProvider).markShared(group.id);
}

/// 받은 텍스트(링크·메시지·백업 내용)를 처리한다 (SPEC F13.2~F13.4).
///
/// 같은 링크를 두 번 묻지 않도록 마지막으로 처리한 링크를 기억한다.
/// [quiet]면 초대가 아닐 때 아무것도 알리지 않는다 (클립보드 자동 감지).
Future<void> handleIncoming(
  BuildContext context,
  WidgetRef ref,
  String text, {
  bool quiet = false,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final bundle = InviteCodec.tryParse(text);
  if (bundle == null) {
    if (!quiet) {
      messenger.showSnackBar(
        const SnackBar(content: Text('초대 링크를 찾지 못했어요. 링크 전체를 붙여넣어 주세요.')),
      );
    }
    return;
  }
  final device = DeviceRepository(ref.read(databaseProvider));
  final fingerprint =
      '${bundle.groupId}@${bundle.exportedAt.toIso8601String()}';
  if (quiet && await device.get('invite.last') == fingerprint) return;
  await device.set('invite.last', fingerprint);

  final service = ref.read(bundleServiceProvider);
  final exists = await service.groupExists(bundle.groupId);
  final role =
      GroupRole.values.where((r) => r.name == bundle.role).firstOrNull ??
      GroupRole.member;
  final preview = exists ? await service.preview(bundle) : null;
  if (!context.mounted) return;

  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(exists ? '"${bundle.groupName}" 변경 사항' : '모임 초대'),
      content: Text(
        exists
            ? (preview!.isEmpty
                  ? '새로운 변경이 없어요.'
                  : '변경 사항: 선수·조건 $preview'
                        '${bundle.lineupCount > 0 ? '\n편성 이력도 함께 맞춰요.' : ''}')
            : '"${bundle.groupName}" 모임에 참여할까요?\n'
                  '선수 ${bundle.playerCount}명 · ${role.label} 권한',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        FilledButton(
          key: const Key('acceptInvite'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(exists ? '반영' : '참여'),
        ),
      ],
    ),
  );
  if (ok != true) return;
  final summary = await service.import(
    bundle,
    mode: ImportMode.merge,
    role: bundle.role ?? GroupRole.member.name,
  );
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        summary.createdGroup
            ? '"${bundle.groupName}" 모임에 참여했어요.'
            : summary.roleUpgraded
            ? '반영했어요 · 이제 운영진이에요.'
            : '반영했어요 · $summary',
      ),
    ),
  );
}

/// 모임 목록의 [초대 링크로 참여]: 링크·메시지를 붙여넣는다.
Future<void> askAndJoin(BuildContext context, WidgetRef ref) async {
  final controller = TextEditingController();
  final clip = await ref.read(clipboardTextProvider)();
  if (clip != null && InviteCodec.tryParse(clip) != null) {
    controller.text = clip;
  }
  if (!context.mounted) return;
  final text = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('초대 링크로 참여'),
      content: TextField(
        key: const Key('invitePaste'),
        controller: controller,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: '카카오톡으로 받은 초대 메시지나 링크를 붙여넣으세요',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          key: const Key('joinSubmit'),
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('확인'),
        ),
      ],
    ),
  );
  if (text == null || text.trim().isEmpty || !context.mounted) return;
  await handleIncoming(context, ref, text);
}
