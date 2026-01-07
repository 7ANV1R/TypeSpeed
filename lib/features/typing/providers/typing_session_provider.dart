import 'dart:async';
import 'dart:math';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:typespeed/features/typing/data/high_score_repository.dart';
import 'package:typespeed/features/typing/data/words.dart';
import 'package:typespeed/features/typing/domain/test_models.dart';

class TypingState {
  final TestStatus status;
  final List<String> targetWords;
  final String typedText;
  final DateTime? startTime;
  final DateTime? endTime;
  final TestSettings settings;
  final double? personalBest;
  final bool isNewRecord;

  const TypingState({
    required this.status,
    required this.targetWords,
    required this.typedText,
    this.startTime,
    this.endTime,
    required this.settings,
    this.personalBest,
    this.isNewRecord = false,
  });

  factory TypingState.initial(TestSettings settings) {
    return TypingState(
      status: .idle,
      targetWords: [],
      typedText: '',
      settings: settings,
    );
  }

  TypingState copyWith({
    TestStatus? status,
    List<String>? targetWords,
    String? typedText,
    DateTime? startTime,
    DateTime? endTime,
    TestSettings? settings,
    double? personalBest,
    bool? isNewRecord,
  }) {
    return TypingState(
      status: status ?? this.status,
      targetWords: targetWords ?? this.targetWords,
      typedText: typedText ?? this.typedText,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      settings: settings ?? this.settings,
      personalBest: personalBest ?? this.personalBest,
      isNewRecord: isNewRecord ?? this.isNewRecord,
    );
  }

  // Helpers
  String get fullTargetText => targetWords.join(' ');

  int get errors {
    int errorCount = 0;
    final minLen = min(typedText.length, fullTargetText.length);
    for (int i = 0; i < minLen; i++) {
      if (typedText[i] != fullTargetText[i]) {
        errorCount++;
      }
    }
    // Extra characters typed beyond target are also errors?
    // Usually in monkeytype you can't type beyond unless it's infinite,
    // but for simple MVP if you type extra, it is wrong.
    if (typedText.length > fullTargetText.length) {
      errorCount += typedText.length - fullTargetText.length;
    }
    return errorCount;
  }

  int get correctCount {
    int count = 0;
    final minLen = min(typedText.length, fullTargetText.length);
    for (int i = 0; i < minLen; i++) {
      if (typedText[i] == fullTargetText[i]) {
        count++;
      }
    }
    return count;
  }

  double get wpm {
    // Net WPM: (All typed - uncorrected errors) / 5 / Time
    // Since we don't track corrected vs uncorrected separately in a complex way yet,
    // we'll just use (Typed - Error) / 5 / Time for Net WPM
    // Standard formula: ((Characters - Errors) / 5) / Minutes

    if (startTime == null) return 0;
    final end = endTime ?? DateTime.now();
    final durationInMinutes =
        end.difference(startTime!).inMilliseconds / 60000.0;
    if (durationInMinutes == 0) return 0;

    final netChars = max(0, typedText.length - errors);
    return (netChars / 5) / durationInMinutes;
  }

  double get rawWpm {
    if (startTime == null) return 0;
    final end = endTime ?? DateTime.now();
    final durationInMinutes =
        end.difference(startTime!).inMilliseconds / 60000.0;
    if (durationInMinutes == 0) return 0;
    // Raw WPM = (All typed / 5) / Time
    return (typedText.length / 5) / durationInMinutes;
  }

  double get accuracy {
    if (typedText.isEmpty) return 100;
    return (correctCount / typedText.length) * 100;
  }
}

class TypingSessionNotifier extends Notifier<TypingState> {
  Timer? _timer;
  final _highScoreRepo = HighScoreRepository();

  @override
  TypingState build() {
    return _generateInitialState(
      const TestSettings(mode: TestMode.time, targetAmount: 30),
    );
  }

  List<String> _generateWords(int count, [String? previousWord]) {
    final random = Random();
    List<String> words = [];
    String? lastWord = previousWord;

    for (int i = 0; i < count; i++) {
      String newWord;
      do {
        newWord = commonWords[random.nextInt(commonWords.length)];
      } while (newWord == lastWord);

      words.add(newWord);
      lastWord = newWord;
    }
    return words;
  }

  TypingState _generateInitialState(TestSettings settings) {
    int count = settings.mode == TestMode.words ? settings.targetAmount : 100;
    List<String> newWords = _generateWords(count);

    return TypingState(
      status: .idle,
      targetWords: newWords,
      typedText: '',
      settings: settings,
    );
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    state = _generateInitialState(state.settings);
  }

  void updateSettings(TestSettings newSettings) {
    state = _generateInitialState(newSettings);
  }

  void start() {
    state = state.copyWith(status: .running, startTime: DateTime.now());

    if (state.settings.mode == TestMode.time) {
      _startTimer();
    }
  }

  void _startTimer() {
    final duration = Duration(seconds: state.settings.targetAmount);
    _timer = Timer(duration, () {
      finish();
    });
  }

  void handleInput(String input) {
    if (state.status == TestStatus.finished ||
        state.status == TestStatus.disqualified) {
      return;
    }

    // Detect cheating (paste/autosuggestion usually adds >1 char at once)
    // We allow length increase > 1 only if it's strictly expected? No, never.
    // However, we must be careful about backspace (length decreases) or replace.
    // length - oldLength > 1 means sudden addition.
    if (input.length - state.typedText.length > 1) {
      _timer?.cancel();
      state = state.copyWith(status: TestStatus.disqualified);
      return;
    }

    if (state.status == TestStatus.idle) {
      start();
    }

    state = state.copyWith(typedText: input);

    if (state.settings.mode == TestMode.words) {
      if (state.typedText.length >= state.fullTargetText.length) {
        finish();
      }
    } else {
      if (state.typedText.length > state.fullTargetText.length - 50) {
        final moreWords = _generateWords(50, state.targetWords.last);
        state = state.copyWith(
          targetWords: [...state.targetWords, ...moreWords],
        );
      }
    }
  }

  void finish() async {
    _timer?.cancel();
    final endTime = DateTime.now();

    // Calculate preliminary wpm to check high score
    // using Net WPM formula consitent with the getter
    double wpm = 0;
    if (state.startTime != null) {
      final durationInMinutes =
          endTime.difference(state.startTime!).inMilliseconds / 60000.0;
      if (durationInMinutes > 0) {
        final int errors = state.errors;
        final netChars = max(0, state.typedText.length - errors);
        wpm = (netChars / 5) / durationInMinutes;
      }
    }

    final modeName = state.settings.mode == TestMode.time ? 'time' : 'words';
    final amount = state.settings.targetAmount;
    final currentBest = await _highScoreRepo.getHighScore(modeName, amount);
    bool isNewRecord = false;
    double bestToDisplay = currentBest;

    if (wpm > currentBest && wpm > 0) {
      isNewRecord = true;
      bestToDisplay = wpm;
      await _highScoreRepo.saveHighScore(modeName, amount, wpm);
    }

    state = state.copyWith(
      status: .finished,
      endTime: endTime,
      isNewRecord: isNewRecord,
      personalBest: bestToDisplay,
    );
  }
}

final typingSessionProvider =
    NotifierProvider<TypingSessionNotifier, TypingState>(
      TypingSessionNotifier.new,
    );
