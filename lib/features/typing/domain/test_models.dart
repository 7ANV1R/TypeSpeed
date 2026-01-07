enum TestMode { words, time }

class TestSettings {
  final TestMode mode;
  final int targetAmount; // Seconds for time, count for words

  const TestSettings({required this.mode, required this.targetAmount});

  TestSettings copyWith({TestMode? mode, int? targetAmount}) {
    return TestSettings(
      mode: mode ?? this.mode,
      targetAmount: targetAmount ?? this.targetAmount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TestSettings &&
        other.mode == mode &&
        other.targetAmount == targetAmount;
  }

  @override
  int get hashCode => mode.hashCode ^ targetAmount.hashCode;
}

enum TestStatus { idle, running, finished, disqualified }
