import 'package:web/web.dart' as web;

String? takeInitialInvite() {
  final hash = web.window.location.hash;
  if (hash.length < 2) return null;
  final String payload;
  try {
    payload = Uri.decodeComponent(hash.substring(1));
  } on Object {
    return null;
  }
  if (!payload.startsWith('MUG')) return null;
  final loc = web.window.location;
  web.window.history.replaceState(null, '', '${loc.pathname}${loc.search}');
  return payload;
}

bool get isStandaloneWebApp =>
    web.window.matchMedia('(display-mode: standalone)').matches;

bool get isIosBrowser =>
    RegExp('iPhone|iPad|iPod').hasMatch(web.window.navigator.userAgent);
