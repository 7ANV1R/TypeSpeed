import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:typespeed/features/typing/domain/test_models.dart';
import 'package:typespeed/features/typing/presentation/widgets/rolling_counter.dart';
import 'package:typespeed/features/typing/presentation/widgets/timer_display.dart';
import 'package:typespeed/features/typing/presentation/widgets/typing_display_area.dart';
import 'package:typespeed/features/typing/providers/typing_session_provider.dart';

class TypingArea extends HookConsumerWidget {
  const TypingArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(typingSessionProvider);
    final notifier = ref.read(typingSessionProvider.notifier);

    final focusNode = useFocusNode();
    final scrollController = useScrollController();

    // Auto focus on load and keep focus
    useEffect(() {
      // Defer focus request until after layout
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (focusNode.canRequestFocus) {
          focusNode.requestFocus();
        }
      });
      return null;
    }, []);

    // Handle typing input
    void handleKey(String value) {
      notifier.handleInput(value);
    }

    // We need to keep a controller to preserve text state for the hidden field
    // But actually, the state source of truth is the provider.
    // We just need to ensure the TextField matches the provider state length or clears when reset.
    final textController = useTextEditingController(text: state.typedText);

    // Sync controller if state was reset (e.g. restart)
    useEffect(() {
      if (state.typedText.isEmpty && textController.text.isNotEmpty) {
        textController.clear();
      }
      return null;
    }, [state.typedText.isEmpty]);

    // Timer display (if time mode)
    final timeDisplay = useMemoized(
      () {
        if (state.settings.mode == TestMode.time) {
          if (state.status == .running &&
              state.startTime != null &&
              state.endTime == null) {
            // This needs a ticker to update UI
            return TimerDisplay(
              startTime: state.startTime!,
              totalSeconds: state.settings.targetAmount,
            );
          }
          return RollingCounter(text: state.settings.targetAmount.toString());
        } else {
          // Word count mode: Show progress (e.g. 5/20)
          // Calculate word count based on spaces?
          final currentWordIndex = state.typedText.split(' ').length;
          return RollingCounter(
            text: '$currentWordIndex / ${state.settings.targetAmount}',
          );
        }
      },
      [
        state.settings.mode,
        state.status,
        state.startTime,
        state.typedText,
        state.settings.targetAmount,
      ],
    );

    return Column(
      children: [
        // HUD
        Container(
          height: 60,
          alignment: Alignment.centerLeft,
          padding: const .only(left: 32),
          child: timeDisplay,
        ),

        Expanded(
          child: GestureDetector(
            onTap: () {
              focusNode.requestFocus();
              SystemChannels.textInput.invokeMethod('TextInput.show');
            },
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                // Hidden Input
                Positioned(
                  width: 1,
                  height: 1,
                  child: Opacity(
                    opacity: 0,
                    child: TextField(
                      focusNode: focusNode,
                      controller: textController,
                      autofocus: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: handleKey,
                      style: const TextStyle(color: Colors.transparent),
                      cursorColor: Colors.transparent,
                      maxLines: 1,
                    ),
                  ),
                ),

                // Actual Display
                Padding(
                  padding: const .symmetric(horizontal: 32.0),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const .only(
                      bottom: 200,
                    ), // Extra padding to allow scrolling up
                    child: WordWrapDisplay(
                      targetWords: state.targetWords,
                      typedText: state.typedText,
                      onActiveWordChanged: (offset) {
                        // Try to scroll to keep active word in view
                        // Simple implementation:
                        // If we had the context of the word widget, we could EnsureVisible.
                        // Here we rely on the wrap.
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
