import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/features/common/web_frame.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget app(Size size) => MediaQuery(
    data: MediaQueryData(size: size),
    child: const MaterialApp(
      home: WebFrame(enabled: true, child: Text('본 화면')),
    ),
  );

  testWidgets('웹: 세로도 지원 — 가로로 돌려 달라는 안내 없음', (tester) async {
    await tester.pumpWidget(app(const Size(390, 844)));
    expect(find.text('폰을 가로로 돌려 주세요'), findsNothing);
    expect(find.text('본 화면', skipOffstage: false), findsOneWidget);
    await tester.pump(const Duration(seconds: 16));
  });

  testWidgets('웹: 가로면 안내 없음', (tester) async {
    await tester.pumpWidget(app(const Size(844, 390)));
    expect(find.text('폰을 가로로 돌려 주세요'), findsNothing);
    await tester.pump(const Duration(seconds: 16));
  });
}
