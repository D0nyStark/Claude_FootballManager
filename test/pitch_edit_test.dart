import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/core/models/models.dart';
import 'package:futsalteammaker/features/pitch/half_court.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/app_harness.dart';
import 'match_flow_test.dart' as flow;

/// 13명 · 6vs6 · 2팀(7·6)으로 구장까지 가서 자동 편성.
Future<void> arrange(WidgetTester tester) async {
  await flow.enterGroup(tester);
  await tapAndSettle(tester, find.text('6 vs 6'));
  await tapAndSettle(tester, find.text('전체 선택'));
  for (final n in flow.regularNames) {
    await flow.tapPlayer(tester, n);
  }
  await tapAndSettle(tester, find.text('다음 →'));
  await tapAndSettle(tester, find.byKey(const Key('makeTeams')));
  await tapAndSettle(tester, find.byKey(const Key('autoArrange')));
}

/// 팀 [team]의 [slot] 원 (구장 카드 순서대로 팀 0, 1).
Finder circleAt(WidgetTester tester, int team, Slot slot) {
  final all = find.byWidgetPredicate(
    (w) => w is PositionCircle && w.slot == slot && w.size > 0,
  );
  final hits = all.evaluate().toList()
    ..sort(
      (a, b) => tester
          .getCenter(find.byWidget(a.widget))
          .dx
          .compareTo(tester.getCenter(find.byWidget(b.widget)).dx),
    );
  return find.byWidget(hits[team].widget);
}

String? nameAt(WidgetTester tester, int team, Slot slot) =>
    tester.widget<PositionCircle>(circleAt(tester, team, slot)).player?.name;

Future<void> dragCircle(WidgetTester tester, Finder from, Finder to) async {
  final start = tester.getCenter(from);
  final end = tester.getCenter(to);
  final g = await tester.startGesture(start);
  await tester.pump(const Duration(milliseconds: 50));
  await g.moveBy(const Offset(12, 12));
  await tester.pump();
  await g.moveTo(end);
  await tester.pump();
  await g.up();
  await settle(tester);
}

int score(WidgetTester tester) =>
    int.parse(tester.widget<Text>(find.byKey(const Key('balanceScore'))).data!);

void main() {
  testWidgets('다른 팀 원끼리 끌어서 맞교환 → 점수 갱신 → 되돌리기·다시하기·초기화', (tester) async {
    await arrange(tester);
    final redPivo = nameAt(tester, 0, Slot.pivo)!;
    final bluePivo = nameAt(tester, 1, Slot.pivo)!;

    await dragCircle(
      tester,
      circleAt(tester, 0, Slot.pivo),
      circleAt(tester, 1, Slot.pivo),
    );
    expect(nameAt(tester, 0, Slot.pivo), bluePivo);
    expect(nameAt(tester, 1, Slot.pivo), redPivo);
    expect(find.byKey(const Key('balanceScore')), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const Key('undo')));
    expect(nameAt(tester, 0, Slot.pivo), redPivo);
    await tapAndSettle(tester, find.byKey(const Key('redo')));
    expect(nameAt(tester, 0, Slot.pivo), bluePivo);
    await tapAndSettle(tester, find.byKey(const Key('resetEdits')));
    expect(nameAt(tester, 0, Slot.pivo), redPivo);
  });

  testWidgets('후보 칩을 원으로 끌면 맞교환', (tester) async {
    await arrange(tester);
    final benchChip = find.byType(Chip);
    expect(benchChip, findsOneWidget);
    final benchName = (tester.widget<Chip>(benchChip).label as Text).data!;
    // 후보가 있는 팀(7명)이 몇 번째 팀인지 찾는다.
    final team =
        tester.getCenter(benchChip).dx <
            tester.getCenter(circleAt(tester, 1, Slot.gk)).dx - 100
        ? 0
        : 1;
    final starter = nameAt(tester, team, Slot.alaLeft)!;

    await dragCircle(tester, benchChip, circleAt(tester, team, Slot.alaLeft));
    expect(nameAt(tester, team, Slot.alaLeft), benchName);
    expect(
      (tester.widget<Chip>(find.byType(Chip)).label as Text).data,
      starter,
    );
  });

  testWidgets('길게 눌러 📌 고정 → 다시 섞어도 같은 팀·자리', (tester) async {
    await arrange(tester);
    final pinned = nameAt(tester, 1, Slot.fixo2)!;
    await tester.longPress(circleAt(tester, 1, Slot.fixo2));
    await settle(tester);
    expect(find.byKey(const Key('pinBadge')), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tapAndSettle(tester, find.byKey(const Key('shuffle')));
      expect(nameAt(tester, 1, Slot.fixo2), pinned);
    }
    // 다시 길게 누르면 고정 해제
    await tester.longPress(circleAt(tester, 1, Slot.fixo2));
    await settle(tester);
    expect(find.byKey(const Key('pinBadge')), findsNothing);
  });

  testWidgets('팀 이름·조끼 색 바꾸기', (tester) async {
    await arrange(tester);
    await tapAndSettle(tester, find.textContaining('🔴 레드'));
    await tester.enterText(find.byKey(const Key('teamName')), '조끼팀');
    await tapAndSettle(tester, find.text('저장'));
    expect(find.textContaining('조끼팀'), findsOneWidget);
  });

  testWidgets('다시 섞기도 되돌리기로 이전 편성으로', (tester) async {
    await arrange(tester);
    final before = [
      for (final s in MatchFormat.sixVsSix.slots) nameAt(tester, 0, s),
    ];
    await tapAndSettle(tester, find.byKey(const Key('shuffle')));
    await tapAndSettle(tester, find.byKey(const Key('undo')));
    expect([
      for (final s in MatchFormat.sixVsSix.slots) nameAt(tester, 0, s),
    ], before);
    expect(score(tester), greaterThan(0));
  });
}
