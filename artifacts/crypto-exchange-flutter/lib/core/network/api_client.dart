import 'dio_client.dart';

// Export DioClient for compatibility
export 'dio_client.dart' show DioClient;

// Type alias for better compatibility with P2P code
typedef ApiClient = DioClient;
