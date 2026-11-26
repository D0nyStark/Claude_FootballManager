/// 웹(아이폰 웹앱) 전용 동작. 앱(안드로이드)·테스트에서는 아무 일도 하지 않는다.
library;

export 'web_env_stub.dart' if (dart.library.js_interop) 'web_env_web.dart';
