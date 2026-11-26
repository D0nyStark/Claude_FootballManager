# 풋살 팀메이커 (Futsal Team Maker)

풋살 모임의 선수·능력치를 미리 등록해 두고, 당일 출전자만 골라 **밸런스가 맞는 팀을 자동으로 편성**하는 Android 앱입니다.
기획 문서는 [SPEC.md](SPEC.md)를 참고하세요.

- 패키지: `com.mug.futsalteammaker`
- Flutter 3.50 / Dart 3.14, Android 기준, 가로 모드 고정

## 구조

```
lib/
  core/            # 순수 Dart (Flutter 의존 없음)
    models/        # Player, PlayerStats, MatchFormat/Slot, Lineup, TeamConstraint
    scoring/       # 공격력·수비력 지표, 슬롯 정규화, 밸런스 점수(0~100), 자리 배치
    balancer/      # 자동 편성 엔진 (시뮬레이티드 어닐링, 후보 선정, 반복 조합 회피)
  data/            # 기기 저장 (drift/SQLite), 저장소, Riverpod 공급자
  features/        # 화면: 모임 목록, 생성 마법사, 모임 홈, 선수 관리, 설정
  app.dart, main.dart
test/core/         # 엔진·점수 단위 테스트 (SPEC §6.8 품질 목표 포함)
```

## 개발

```bash
flutter pub get
dart run build_runner build   # DB 테이블을 바꿨을 때만 (app_database.g.dart 재생성)
flutter analyze
flutter test
flutter run            # Android 기기/에뮬레이터
flutter build apk      # 데모 배포용 APK
```

## 진행 상황

| 단계 | 상태 |
|---|---|
| M0 셋업 (프로젝트, 가로 고정, CI) | ✅ |
| M1 편성 엔진 + 테스트 | ✅ |
| M2 모임·선수 관리 (모임 목록, 생성 마법사, 선수·제약, 기기 저장) | ✅ |
| M3 출전 덱·팀 설정 (3단 덱, 게스트, 자동 보존, 팀 수·키퍼·당일 조건, 임시 결과 화면) | ✅ |
| 튜토리얼 말풍선 (화면별 첫 방문, 모두 건너뛰기, 사용법 다시 보기) | ✅ |
| M4~M7 | ⏳ |
