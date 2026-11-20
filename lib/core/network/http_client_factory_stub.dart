import 'package:http/http.dart' as http;

/// Fallback factory for platforms without browser JS interop (desktop, tests).
http.Client createPlatformClient() => http.Client();
