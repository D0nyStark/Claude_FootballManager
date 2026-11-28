# 풋살 팀메이커 (Futsal Team Maker)

풋살 모임의 선수·능력치를 미리 등록해 두고, 당일 출전자만 골라 **밸런스가 맞는 팀을 자동으로 편성**하는 Android 앱입니다. 아이폰은 같은 코드로 만든 **웹앱(PWA)**으로 씁니다.
기획 문서는 [SPEC.md](SPEC.md)를 참고하세요.

- 패키지: `com.mug.futsalteammaker`
- Flutter 3.50 / Dart 3.14, Android 기준, 세로·가로 모두 지원 (1.3.0부터, 그 전에는 가로 고정)

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

## 데모 설치 (Android)

1. `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
2. APK를 GitHub Releases에 올린다 (안내 페이지의 [앱 설치]가 `releases/latest`로 연결됨).
3. 폰에서 APK를 받아 설치 → "출처를 알 수 없는 앱 설치" 허용이 필요할 수 있다.

- 지원: Android 7.0(API 24) 이상, 세로·가로 모두 지원
- 데모 빌드는 **디버그 키로 서명**되어 있다. 스토어 출시 전에는 별도 서명 키를 만들어 `android/key.properties`로 연결해야 한다 (키 파일은 저장소에 올리지 않는다).
- 앱 아이콘: `python3 tool/make_icon.py`로 다시 만들 수 있다.

## 아이폰용 웹앱

```bash
./tool/build_web.sh   # flutter build web → 쓰지 않는 렌더러 파일 정리 → docs/app/
```

- GitHub Pages(아래)를 켜면 `https://d0nystark.github.io/Claude_FootballManager/app/`에서 열린다.
- 아이폰 사파리에서 열고 공유 버튼 → **홈 화면에 추가**. 세로·가로 모두 쓸 수 있다.
- 앱 코드를 고치면 `tool/build_web.sh`를 다시 실행해 `docs/app/`을 함께 커밋한다.
- `web/sqlite3.wasm`, `web/drift_worker.js`는 drift/sqlite3 패키지 버전에 맞춘 파일이다 (sqlite3 3.9.2, drift 2.35.4). 패키지를 올리면 같은 버전의 릴리스 파일로 바꾼다.

## 디자인 자산

- `assets/fonts/Paperlogy-*.ttf` — 페이퍼로지(SIL OFL 1.1). 라이선스 원문은 `assets/fonts/OFL.txt`. 웹 폰트(woff2)를 앱용 ttf로 형식만 바꿨다.
- `assets/home_bg.jpg` — 홈 배경 사진. ⚠️ 지금 파일은 **pngtree 워터마크가 있는 시안용 이미지**라 스토어 출시 전에 라이선스가 있는 사진으로 바꿔야 한다(파일만 교체하면 됨).

## 초대 링크 안내 페이지

`docs/join.html`을 GitHub Pages로 올린다 (저장소 Settings → Pages → Branch: `main` / `/docs`).
주소는 `lib/config.dart`의 `AppConfig.inviteBaseUrl`에서 바꾼다.

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
| M4 구장 GUI (반쪽 구장 나란히, 포지션 원, 자동 편성 애니메이션, 실시간 밸런스 헤더, 후보) | ✅ |
| M5 수동 수정 (끌어서 맞교환·후보 교체, 📌 고정, 되돌리기/다시하기/초기화, 팀 이름·색) | ✅ |
| M6 확정·공유·백업 (편성 이력 3개·반복 회피 연결, 텍스트/이미지 공유, .mug 백업·병합, 모임 설정) | ✅ |
| M6.5 초대 링크 (MUG2 짧은 형식, 운영진/멤버 초대, 변경 공유, 안내 페이지, 클립보드 감지) | ✅ |
| M7 데모 빌드 (앱 아이콘, 릴리스 APK: arm64 21.7MB / 범용 62MB) | ✅ |
| 아이폰용 웹앱 (PWA, GitHub Pages `/app/`, 세로 안내, 웹 초대 링크) | ✅ |
| UI 개편 1.3.0 (상단 아이콘 이동, 유리 디자인·포인트 `#3B6A41`, 페이퍼로지, 세로 지원, 풋살/축구(준비 중), 팀 인원 4~7) | ✅ |
| 1.3.1 (모든 화면 유리 패널, 화면 모드: 앱 밝게/어둡게 선택·웹 밝게 고정, 캡션 400) | ✅ |
| 실기기 시범 사용 · 피드백 반영 | ⏳ |
