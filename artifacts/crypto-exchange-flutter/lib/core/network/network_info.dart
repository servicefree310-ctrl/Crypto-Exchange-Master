import 'package:injectable/injectable.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

@Injectable(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // For now, assume we have internet connection
    // In a real implementation, you would use connectivity_plus or internet_connection_checker package
    return true;
  }
}
