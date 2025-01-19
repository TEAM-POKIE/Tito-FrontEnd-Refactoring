import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tito_app/core/provider/chat_view_provider.dart';

class TimerState {
  final Duration remainingTime;

  TimerState({required this.remainingTime});

  TimerState copyWith({Duration? remainingTime}) {
    return TimerState(
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  final int debatedTimeLimit;
  static const String _prefsKeyRemainingTime = "remainingTime";
  static const String _prefsKeyStartTime = "startTime";
  final StateNotifierProviderRef ref;

  TimerNotifier({required this.ref, this.debatedTimeLimit = 8})
      : super(TimerState(remainingTime: Duration(minutes: debatedTimeLimit))) {
    _loadTimerState();
  }

  Future<void> _loadTimerState() async {
    if (!mounted) return; // mounted 확인

    final prefs = await SharedPreferences.getInstance();
    final int? seconds = prefs.getInt(_prefsKeyRemainingTime);
    final int? startTimeMillis = prefs.getInt(_prefsKeyStartTime);

    if (seconds != null && startTimeMillis != null) {
      final startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
      final now = DateTime.now();
      final elapsed = now.difference(startTime).inSeconds;
      final newRemainingTime = Duration(seconds: seconds - elapsed);

      if (newRemainingTime > Duration.zero) {
        if (mounted) {
          state = state.copyWith(remainingTime: newRemainingTime);
          _updateChatState(newRemainingTime);
        }
        startTimer(); // 타이머 시작
      } else {
        _clearSavedTimerState();
      }
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // mounted 확인
    await prefs.setInt(_prefsKeyRemainingTime, state.remainingTime.inSeconds);
    await prefs.setInt(
        _prefsKeyStartTime, DateTime.now().millisecondsSinceEpoch);
  }

  void startTimer({DateTime? startTime}) {
    if (_timer != null && _timer!.isActive) {
      return;
    }

    final DateTime now = DateTime.now();
    if (startTime != null) {
      final int elapsed = now.difference(startTime).inSeconds;
      final int remaining = debatedTimeLimit * 60 - elapsed;
      if (remaining > 0) {
        if (mounted) {
          state = state.copyWith(remainingTime: Duration(seconds: remaining));
        }
      } else {
        if (mounted) {
          state = TimerState(remainingTime: Duration.zero);
        }
        _clearSavedTimerState();
        return;
      }
    }

    _saveTimerState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingTime.inSeconds > 0) {
        final newRemainingTime =
            state.remainingTime - const Duration(seconds: 1);
        if (mounted) {
          state = state.copyWith(remainingTime: newRemainingTime);
          _updateChatState(newRemainingTime);
        }

        if (newRemainingTime.inSeconds % 10 == 0) {
          _saveTimerState(); // 주기적으로만 저장
        }
      } else {
        _timer?.cancel();
        _clearSavedTimerState();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void resetTimer({DateTime? startTime}) {
    stopTimer();

    final DateTime now = DateTime.now();
    final int elapsed =
        startTime != null ? now.difference(startTime).inSeconds : 0;
    final int remaining = debatedTimeLimit * 60 - elapsed;

    if (remaining > 0) {
      if (mounted) {
        state = TimerState(remainingTime: Duration(seconds: remaining));
        _updateChatState(state.remainingTime);
        startTimer(); // 타이머를 다시 시작
      }
    } else {
      _clearSavedTimerState();
      if (mounted) {
        state = TimerState(remainingTime: Duration.zero);
      }
    }
  }

  void _updateChatState(Duration newRemainingTime) {
    final chatNotifier = ref.read(chatInfoProvider.notifier);
    if (mounted) {
      chatNotifier.updateRemainTimer(newRemainingTime);
    }
  }

  Future<void> _clearSavedTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyRemainingTime);
    await prefs.remove(_prefsKeyStartTime);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
