import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int initialTimeInSeconds;
  final VoidCallback onExpire;
  final bool showWarning;
  final int warningThreshold;

  const CountdownTimer({
    super.key,
    required this.initialTimeInSeconds,
    required this.onExpire,
    this.showWarning = true,
    this.warningThreshold = 300, // 5 minutes
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with TickerProviderStateMixin {
  late int _timeLeft;
  late bool _isWarning;
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.initialTimeInSeconds;
    _isWarning = false;

    _controller = AnimationController(
      duration: Duration(seconds: widget.initialTimeInSeconds),
      vsync: this,
    );

    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _timeLeft--;
          if (_timeLeft <= widget.warningThreshold && widget.showWarning) {
            _isWarning = true;
          }
        });

        if (_timeLeft <= 0) {
          widget.onExpire();
        } else {
          _startTimer();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_timeLeft <= 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50.withValues(alpha: isDark ? 0.1 : 1.0),
          border: Border.all(
            color: Colors.red.shade200.withValues(alpha: isDark ? 0.3 : 1.0),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Session Expired',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.red.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Please refresh to start a new deposit session',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final minutes = _timeLeft ~/ 60;
    final seconds = _timeLeft % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isWarning
              ? [
                  Colors.red.shade50.withValues(alpha: isDark ? 0.1 : 1.0),
                  Colors.orange.shade50.withValues(alpha: isDark ? 0.1 : 1.0),
                ]
              : [
                  Colors.blue.shade50.withValues(alpha: isDark ? 0.1 : 1.0),
                  Colors.indigo.shade50.withValues(alpha: isDark ? 0.1 : 1.0),
                ],
        ),
        border: Border.all(
          color: _isWarning
              ? Colors.red.shade200.withValues(alpha: isDark ? 0.3 : 1.0)
              : Colors.blue.shade200.withValues(alpha: isDark ? 0.3 : 1.0),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                value: _progress.value,
                backgroundColor:
                    Colors.grey.shade300.withValues(alpha: isDark ? 0.3 : 1.0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isWarning ? Colors.red.shade500 : Colors.blue.shade500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Timer header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isWarning
                      ? Colors.red.shade100.withValues(alpha: isDark ? 0.2 : 1.0)
                      : Colors.blue.shade100.withValues(alpha: isDark ? 0.2 : 1.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time,
                  color:
                      _isWarning ? Colors.red.shade600 : Colors.blue.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isWarning
                    ? 'Deposit Expiring Soon!'
                    : 'Deposit Session Active',
                style: theme.textTheme.titleMedium?.copyWith(
                  color:
                      _isWarning ? Colors.red.shade700 : Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Time display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeUnit(minutes, 'MIN', isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  ':',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color:
                        _isWarning ? Colors.red.shade500 : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTimeUnit(seconds, 'SEC', isDark),
            ],
          ),
          const SizedBox(height: 16),

          // Warning text
          Text(
            _isWarning
                ? '⚠️ Your deposit session will expire soon. Please complete your deposit to avoid losing this address.'
                : '🔒 Your deposit address is reserved. Complete your deposit within the time limit.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: _isWarning
                  ? Colors.red.shade600.withValues(alpha: 0.8)
                  : Colors.blue.shade600.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(int value, String label, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _isWarning
                  ? [
                      Colors.red.shade50.withValues(alpha: isDark ? 0.2 : 1.0),
                      Colors.red.shade100.withValues(alpha: isDark ? 0.3 : 1.0),
                    ]
                  : [
                      Colors.grey.shade50.withValues(alpha: isDark ? 0.1 : 1.0),
                      Colors.grey.shade100.withValues(alpha: isDark ? 0.2 : 1.0),
                    ],
            ),
            border: Border.all(
              color: _isWarning
                  ? Colors.red.shade200.withValues(alpha: isDark ? 0.3 : 1.0)
                  : Colors.grey.shade300.withValues(alpha: isDark ? 0.3 : 1.0),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: _isWarning
                  ? Colors.red.shade600
                  : (isDark ? Colors.white : Colors.grey.shade900),
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
