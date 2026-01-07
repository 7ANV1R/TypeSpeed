import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:typespeed/common/constants/app_colors.dart';
import 'package:typespeed/features/typing/domain/test_models.dart';
import 'package:typespeed/features/typing/presentation/result_view.dart';
import 'package:typespeed/features/typing/presentation/typing_area.dart';
import 'package:typespeed/features/typing/presentation/widgets/mode_selector.dart';
import 'package:typespeed/features/typing/providers/typing_session_provider.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typingState = ref.watch(typingSessionProvider);
    final notifier = ref.read(typingSessionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: .min,
          mainAxisAlignment: .center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedKeyboard,
              color: AppColors.primary,
            ),
            SizedBox(width: 10),
            Text('TypeSpeed', style: TextStyle(color: AppColors.textActive)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Visibility(
                visible: typingState.status == .idle,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: ModeSelector(currentSettings: typingState.settings),
              ),

              const SizedBox(height: 50),

              Expanded(
                child:
                    (typingState.status == TestStatus.finished ||
                        typingState.status == TestStatus.disqualified)
                    ? const ResultView()
                    : const TypingArea(),
              ),

              const SizedBox(height: 20),

              // Bottom Controls
              Column(
                children: [
                  if (typingState.status == .idle)
                    const Padding(
                      padding: .only(bottom: 16),
                      child: Text(
                        "Tap to start",
                        style: TextStyle(color: AppColors.textMain),
                      ),
                    ),

                  if (typingState.status != .finished)
                    IconButton(
                      onPressed: notifier.reset,
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedRefresh,
                        color: AppColors.textMain,
                      ),
                      tooltip: 'Restart Test',
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
