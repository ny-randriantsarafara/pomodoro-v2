/// Stub for non-web platforms - these should never be called
String getWebOrigin() {
  throw UnsupportedError('getWebOrigin is only supported on web');
}

String getWebScheme() {
  throw UnsupportedError('getWebScheme is only supported on web');
}
