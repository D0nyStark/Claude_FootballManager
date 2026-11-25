import 'package:material_ui/material_ui.dart';

/// 첫 화면: 모임 목록 (SPEC F11, §8.2).
///
/// M0에서는 화면 골격만 둔다. 모임 생성·초대 참여는 M2/M6.5에서 구현한다.
class GroupListPage extends StatelessWidget {
  const GroupListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('풋살 팀메이커'),
        actions: [
          TextButton.icon(
            onPressed: null,
            icon: const Icon(Icons.link),
            label: const Text('초대 링크로 참여'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 200,
            height: 140,
            child: Card.outlined(
              child: InkWell(
                onTap: null,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      const Text('새 모임 만들기'),
                      Text('준비 중', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
