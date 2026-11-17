import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

/// Web factory configuring [BrowserClient] with credentials enabled
/// so that cookies (sessionid and csrftoken) are sent across requests.
http.Client createPlatformClient() {
  final client = BrowserClient()..withCredentials = true;
  return client;
}
