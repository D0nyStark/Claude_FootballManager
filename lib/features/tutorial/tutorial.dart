import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/providers.dart';
import '../../data/repositories/device_repository.dart';
import 'coach_marks.dart';

/// 튜토리얼이 있는 화면 (SPEC F14). 화면마다 처음 들어갈 때 한 번 보여준다.
enum TutorialScreen { groupList, groupHome, players, deck, teamSetup, pitch }

/// 테스트에서는 꺼 둔다.
final tutorialEnabledProvider = Provider<bool>((ref) => true);

final tutorialServiceProvider = Provider(
  (ref) => TutorialService(
    DeviceRepository(ref.watch(databaseProvider)),
    enabled: ref.watch(tutorialEnabledProvider),
  ),
);

/// 어떤 화면의 튜토리얼을 봤는지 기기에 기억한다 (공유되지 않음).
class TutorialService {
  TutorialService(this._repo, {required this.enabled});

  final DeviceRepository _repo;
  final bool enabled;

  static const _prefix = 'tutorial.';
  static const _offKey = '${_prefix}off';

  /// 한 번에 한 화면의 튜토리얼만 띄운다.
  bool _showing = false;

  Future<bool> shouldShow(TutorialScreen screen) async {
    if (!enabled || _showing) return false;
    if (await _repo.get(_offKey) == '1') return false;
    return await _repo.get('$_prefix${screen.name}') != '1';
  }

  Future<void> markDone(TutorialScreen screen) =>
      _repo.set('$_prefix${screen.name}', '1');

  /// [모두 건너뛰기]: 앞으로 어떤 화면에서도 보여주지 않는다.
  Future<void> disableAll() => _repo.set(_offKey, '1');

  /// 설정 > 사용법 다시 보기.
  Future<void> reset() => _repo.removePrefix(_prefix);
}

/// 화면을 감싸서 [CoachTarget]을 모으고, 처음 들어왔을 때 말풍선을 띄운다.
class TutorialHost extends ConsumerStatefulWidget {
  const TutorialHost({
    super.key,
    required this.screen,
    required this.steps,
    required this.child,
    this.ready = true,
  });

  final TutorialScreen screen;

  /// 보여줄 순간에 만든다 (그때의 역할·데이터에 맞춰 문구를 고를 수 있게).
  final List<CoachStep> Function() steps;

  /// 데이터가 다 불러와져 대상이 화면에 그려졌을 때 true.
  final bool ready;
  final Widget child;

  @override
  ConsumerState<TutorialHost> createState() => _TutorialHostState();
}

class _TutorialHostState extends ConsumerState<TutorialHost> {
  final _scope = GlobalKey<CoachScopeState>();
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    if (widget.ready && !_checked) {
      _checked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
    }
    return CoachScope(key: _scope, child: widget.child);
  }

  Future<void> _maybeShow() async {
    final service = ref.read(tutorialServiceProvider);
    if (!await service.shouldShow(widget.screen)) return;
    // 화면 전환 애니메이션이 끝난 뒤 위치를 잰다.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final scope = _scope.currentState;
    if (!mounted || scope == null || service._showing) return;
    if (ModalRoute.of(context)?.isCurrent == false) return;
    service._showing = true;
    try {
      final result = await scope.show(widget.steps());
      if (result == CoachResult.skippedAll) {
        await service.disableAll();
      } else {
        await service.markDone(widget.screen);
      }
    } finally {
      service._showing = false;
    }
  }
}
