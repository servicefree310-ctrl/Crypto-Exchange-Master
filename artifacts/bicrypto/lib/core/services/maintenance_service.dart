import 'dart:async';
import 'dart:developer' as dev;
import 'package:injectable/injectable.dart';

@singleton
class MaintenanceService {
  // Maintenance state
  bool _isInMaintenance = false;
  String _maintenanceMessage = 'Server maintenance in progress';

  // Stream controller for maintenance state
  final _maintenanceController = StreamController<bool>.broadcast();

  // Public getters
  bool get isInMaintenance => _isInMaintenance;
  String get maintenanceMessage => _maintenanceMessage;
  Stream<bool> get maintenanceStream => _maintenanceController.stream;

  /// Set maintenance mode
  void setMaintenanceMode(bool inMaintenance, [String? message]) {
    _isInMaintenance = inMaintenance;
    if (message != null) {
      _maintenanceMessage = message;
    }
    _maintenanceController.add(_isInMaintenance);

    dev.log(
        '🚧 MAINTENANCE: ${inMaintenance ? "Entered" : "Exited"} maintenance mode');
  }

  /// Check if error indicates maintenance (503 or connection issues)
  bool isMaintenanceError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('503') ||
        errorStr.contains('service unavailable') ||
        errorStr.contains('maintenance') ||
        errorStr.contains('websocket') && errorStr.contains('not upgraded');
  }

  /// Handle service error and determine if it's maintenance
  void handleServiceError(dynamic error, String serviceName) {
    if (isMaintenanceError(error)) {
      setMaintenanceMode(
          true, 'Server is under maintenance. Using offline mode.');
      dev.log('🚧 MAINTENANCE: $serviceName detected maintenance mode: $error');
    }
  }

  /// Clear maintenance mode
  void clearMaintenanceMode() {
    setMaintenanceMode(false);
  }

  void dispose() {
    _maintenanceController.close();
  }
}
