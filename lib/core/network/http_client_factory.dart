import 'package:http/http.dart' as http;

import 'http_client_factory_stub.dart'
    if (dart.library.js_interop) 'http_client_factory_web.dart';

/// Instantiates an appropriate [http.Client] for the current runtime.
/// On Flutter Web, configures withCredentials = true.
http.Client createClient() => createPlatformClient();
