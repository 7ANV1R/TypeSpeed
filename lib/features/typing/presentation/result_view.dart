import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:typespeed/common/constants/app_colors.dart';
import 'package:typespeed/features/typing/domain/test_models.dart';
import 'package:typespeed/features/typing/presentation/widgets/disqualified_view.dart';
import 'package:typespeed/features/typing/providers/typing_session_provider.dart';

class ResultView extends HookConsumerWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(typingSessionProvider);
    final controller = useMemoized(
      () => ConfettiController(duration: const Duration(seconds: 3)),
    );

    useEffect(() {
      if (state.isNewRecord) {
        controller.play();
      }
      return controller.dispose;
    }, []);

    if (state.status == TestStatus.disqualified) {
      return const DisqualifiedView();
    }

    return Stack(
      children: [
        if (state.isNewRecord) ...[
          // Left Cannon
          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: controller,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              blastDirection: 0, // usually right
              numberOfParticles: 30,
              minBlastForce: 10,
              maxBlastForce: 30,
              minimumSize: const Size(5, 5),
              maximumSize: const Size(10, 5),
              colors: const [
                AppColors.primary,
                AppColors.textActive,
                AppColors.caret,
                AppColors.error,
                Colors.white,
              ],
              gravity: 0.3,
            ),
          ),
          // Right Cannon
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: controller,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              blastDirection: 3.14, // usually left
              numberOfParticles: 30,
              minBlastForce: 10,
              maxBlastForce: 30,
              minimumSize: const Size(5, 5),
              maximumSize: const Size(10, 5),
              colors: const [
                AppColors.primary,
                AppColors.textActive,
                AppColors.caret,
                AppColors.error,
                Colors.white,
              ],
              gravity: 0.3,
            ),
          ),
        ],
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                      state.isNewRecord
                          ? 'New Personal Best!'
                          : 'Test Completed',
                      style: const TextStyle(
                        fontSize: 32,
                        color: AppColors.textMain,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.5, end: 0, duration: 500.ms),
                const SizedBox(height: 48),

                Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: .end,
                      children: [
                        _BigStat(
                          label: 'wpm',
                          value: state.wpm.toStringAsFixed(0),
                        ),
                        const SizedBox(width: 64),
                        _BigStat(
                          label: 'acc',
                          value: '${state.accuracy.toStringAsFixed(0)}%',
                        ),
                      ],
                    )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.5, end: 0, duration: 500.ms),

                const SizedBox(height: 48),

                Wrap(
                      spacing: 48,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [
                        _SmallStat(
                          label: 'raw',
                          value: state.rawWpm.toStringAsFixed(0),
                        ),
                        _SmallStat(
                          label: 'characters',
                          value: '${state.correctCount}/${state.errors}',
                        ),
                        _SmallStat(
                          label: 'time',
                          value: '${state.settings.targetAmount}s',
                        ),
                        _SmallStat(
                          label: 'best',
                          value: (state.personalBest ?? 0).toStringAsFixed(0),
                          isHighlight: state.isNewRecord,
                        ),
                      ],
                    )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.5, end: 0, duration: 500.ms),

                const SizedBox(height: 64),

                IconButton(
                      onPressed: () {
                        ref.read(typingSessionProvider.notifier).reset();
                      },
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedRefresh,
                        color: AppColors.textActive,
                        size: 32,
                      ),
                      tooltip: 'Restart Test',
                    )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 500.ms)
                    .scale(duration: 300.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BigStat extends StatelessWidget {
  final String label;
  final String value;

  const _BigStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 32, color: AppColors.textMain),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 64,
            color: AppColors.primary,
            height: 1.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _SmallStat({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isHighlight ? AppColors.primary : AppColors.textMain,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            color: isHighlight ? AppColors.primary : AppColors.textActive,
            height: 1.0,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
