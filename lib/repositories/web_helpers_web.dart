import 'package:web/web.dart' as web;

/// Gets the current browser origin (e.g., http://localhost:5000 or https://example.com)
String getWebOrigin() {
  return web.window.location.origin;
}

/// Gets the current browser URL scheme (http or https)
String getWebScheme() {
  return web.window.location.protocol.replaceAll(':', '');
}
