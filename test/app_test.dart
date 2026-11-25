import 'dart:ui' show Size;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/app.dart';

void main() {
  testWidgets('첫 화면에 앱 이름과 모임 만들기가 보인다', (tester) async {
    tester.view.physicalSize = const Size(1600, 720); // 가로 폰 (800×360dp @2x)
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: FutsalTeamMakerApp()));

    expect(find.text('풋살 팀메이커'), findsOneWidget);
    expect(find.text('새 모임 만들기'), findsOneWidget);
    expect(find.text('초대 링크로 참여'), findsOneWidget);
  });
}
