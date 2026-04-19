import 'dart:async';

/// A utility class that delays the execution of a function
/// until a certain amount of time has passed without it being called again.
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  /// Runs [action] after [milliseconds] delay.
  /// If called again before the delay, the previous call is cancelled.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancels any pending action
  void cancel() {
    _timer?.cancel();
  }

  /// Disposes the timer
  void dispose() {
    _timer?.cancel();
  }
}
