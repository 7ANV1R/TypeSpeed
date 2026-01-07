import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:typespeed/features/typing/presentation/widgets/rolling_counter.dart';

class TimerDisplay extends HookWidget {
  final DateTime startTime;
  final int totalSeconds;

  const TimerDisplay({
    super.key,
    required this.startTime,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final timeLeft = useState(totalSeconds);

    useTick((_) {
      final elapsed = DateTime.now().difference(startTime).inSeconds;
      final remaining = totalSeconds - elapsed;
      if (remaining != timeLeft.value) {
        timeLeft.value = remaining > 0 ? remaining : 0;
      }
    });

    return RollingCounter(text: timeLeft.value.toString());
  }
}

// Hook for ticker
void useTick(void Function(Duration) onTick) {
  final tickerProvider = useSingleTickerProvider();
  useEffect(() {
    final ticker = tickerProvider.createTicker(onTick);
    ticker.start();
    return ticker.dispose;
  }, []);
}
