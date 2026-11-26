/// 배포 환경 설정 (한곳에서 바꾼다).
abstract final class AppConfig {
  /// 초대 링크 안내 페이지 (GitHub Pages의 docs/join.html, SPEC F13.3).
  /// 데이터는 '#' 뒤에 있어 페이지 호스팅 쪽으로 전송되지 않는다.
  static const inviteBaseUrl =
      'https://d0nystark.github.io/Claude_FootballManager/join.html';

  /// 앱이 링크를 직접 받는 주소 (안내 페이지의 [앱에서 열기]가 사용).
  static const appScheme = 'futsalteammaker';

  /// 데모 APK 내려받기 (GitHub Releases).
  static const apkUrl =
      'https://github.com/D0nyStark/Claude_FootballManager/releases/latest';
}
