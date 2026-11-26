import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import 'share_service.dart';

/// 확정 후 공유 창 (SPEC F8.1~F8.3): 텍스트 복사·공유, 구장 이미지 공유.
Future<void> showShareSheet(
  BuildContext context, {
  required ShareService service,
  required String Function(bool withStats) text,
  Future<Uint8List?> Function()? image,
  bool canIncludeStats = true,
  String title = '편성 공유',
  Future<String> Function()? updateLink,
  Future<void> Function()? onLinkShared,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  // 가로 폰은 높이가 낮아 기본 높이(화면의 9/16)로는 잘린다.
  isScrollControlled: true,
  constraints: BoxConstraints(
    maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    maxWidth: 720,
  ),
  builder: (_) => _ShareSheet(
    service: service,
    text: text,
    image: image,
    canIncludeStats: canIncludeStats,
    title: title,
    updateLink: updateLink,
    onLinkShared: onLinkShared,
  ),
);

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({
    required this.service,
    required this.text,
    required this.image,
    required this.canIncludeStats,
    required this.title,
    this.updateLink,
    this.onLinkShared,
  });

  final ShareService service;
  final String Function(bool withStats) text;
  final Future<Uint8List?> Function()? image;
  final bool canIncludeStats;
  final String title;

  /// "모임 업데이트 링크 함께 보내기" (SPEC F13.4).
  final Future<String> Function()? updateLink;
  final Future<void> Function()? onLinkShared;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  /// 기본: 능력치 숨김, 밸런스 점수만 (SPEC F8.3).
  bool _withStats = false;
  bool _busy = false;
  bool _withLink = false;
  String? _link;

  Future<void> _toggleLink(bool on) async {
    if (on && _link == null) {
      setState(() => _busy = true);
      _link = await widget.updateLink!();
      if (!mounted) return;
    }
    setState(() {
      _withLink = on;
      _busy = false;
    });
  }

  Future<void> _do(Future<void> Function() action, String done) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (_withLink) await widget.onLinkShared?.call();
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = widget.text(_withStats);
    final preview = _withLink && _link != null ? '$base\n\n$_link' : base;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    key: const Key('sharePreview'),
                    constraints: const BoxConstraints(maxHeight: 110),
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Text(preview, style: theme.textTheme.bodySmall),
                    ),
                  ),
                  if (widget.canIncludeStats)
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('팀별 OVR 포함'),
                      value: _withStats,
                      onChanged: (v) => setState(() => _withStats = v),
                    ),
                  if (widget.updateLink != null)
                    SwitchListTile(
                      key: const Key('withUpdateLink'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('모임 업데이트 링크 함께 보내기'),
                      subtitle: const Text('받은 사람의 선수 명단·이력도 함께 맞춰져요'),
                      value: _withLink,
                      onChanged: _busy ? null : _toggleLink,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 170,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    key: const Key('copyText'),
                    onPressed: _busy
                        ? null
                        : () => _do(
                            () => widget.service.copyText(preview),
                            '복사했어요. 카카오톡에 붙여넣으세요.',
                          ),
                    icon: const Icon(Icons.copy),
                    label: const Text('텍스트 복사'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const Key('shareText'),
                    onPressed: _busy
                        ? null
                        : () => _do(
                            () => widget.service.shareText(preview),
                            '공유했어요.',
                          ),
                    icon: const Icon(Icons.share),
                    label: const Text('텍스트 공유'),
                  ),
                  if (widget.image != null) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: const Key('shareImage'),
                      onPressed: _busy
                          ? null
                          : () => _do(() async {
                              final png = await widget.image!();
                              if (png != null) {
                                await widget.service.shareImage(
                                  png,
                                  text: preview,
                                );
                              }
                            }, '공유했어요.'),
                      icon: const Icon(Icons.image),
                      label: const Text('이미지 공유'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
