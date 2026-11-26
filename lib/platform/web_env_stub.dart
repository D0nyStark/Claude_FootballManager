/// 웹앱 주소의 '#' 뒤 초대 묶음을 꺼내고 주소에서 지운다 (새로고침 때 다시 묻지 않게).
String? takeInitialInvite() => null;

/// 홈 화면에 추가해서 실행 중인지 (브라우저 탭이 아님).
bool get isStandaloneWebApp => true;

/// 아이폰·아이패드 브라우저인지.
bool get isIosBrowser => false;
