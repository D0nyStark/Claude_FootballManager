import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';

import '../../platform/web_env.dart';

/// 웹앱 전용 겉틀.
/// - 웹은 화면 방향을 고정할 수 없어서, 세로로 들면 "가로로 돌려 주세요"를 덮어 보여준다
///   (아래 화면은 그대로 살아 있어 입력 중이던 내용이 사라지지 않는다).
/// - 아이폰 사파리 탭에서 열었으면 "홈 화면에 추가" 안내를 한 번 보여준다.
class WebFrame extends StatefulWidget {
  const WebFrame({super.key, required this.child, this.enabled = kIsWeb});

  final Widget child;
  final bool enabled;

  @override
  State<WebFrame> createState() => _WebFrameState();
}

class _WebFrameState extends State<WebFrame> {
  bool _hintClosed = false;

  @override
  void initState() {
    super.initState();
    // 화면 아래쪽(후보 줄 등)을 오래 가리지 않게 잠시 뒤 저절로 닫는다.
    if (widget.enabled) {
      Future<void>.delayed(const Duration(seconds: 15), () {
        if (mounted) setState(() => _hintClosed = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    final size = MediaQuery.sizeOf(context);
    final portrait = size.height > size.width;
    final showHint = !_hintClosed && isIosBrowser && !isStandaloneWebApp;
    final theme = Theme.of(context);
    return Stack(
      children: [
        widget.child,
        if (showHint && !portrait)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.inverseSurface,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '사파리 공유 버튼 → "홈 화면에 추가"로 설치해서 쓰세요 '
                        '(사파리 탭은 오래 안 쓰면 데이터가 지워질 수 있어요)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: '닫기',
                      color: theme.colorScheme.onInverseSurface,
                      onPressed: () => setState(() => _hintClosed = true),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (portrait)
          Positioned.fill(
            child: Material(
              color: theme.colorScheme.surface,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.screen_rotation,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text('폰을 가로로 돌려 주세요', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        '풋살 팀메이커는 가로 화면 전용이에요.\n'
                        '돌려도 그대로면 제어 센터에서 "화면 방향 잠금"을 꺼 주세요.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
