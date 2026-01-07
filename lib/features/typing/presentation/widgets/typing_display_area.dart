import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:typespeed/common/constants/app_colors.dart';

class WordWrapDisplay extends StatelessWidget {
  final List<String> targetWords;
  final String typedText;
  final Function(double)? onActiveWordChanged;

  const WordWrapDisplay({
    super.key,
    required this.targetWords,
    required this.typedText,
    this.onActiveWordChanged,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> wordWidgets = [];

    final portions = typedText.split(' ');
    final activeIndex = portions.length - 1;

    for (int i = 0; i < targetWords.length; i++) {
      final targetWord = targetWords[i];

      String typedWordPart = "";
      bool isActive = i == activeIndex;
      bool isPast = i < activeIndex;

      if (i < portions.length) {
        typedWordPart = portions[i];
      }

      wordWidgets.add(
        _WordWidget(
          targetWord: targetWord,
          typedWord: typedWordPart,
          isActive: isActive,
          isPast: isPast,
          index: i,
        ),
      );
    }

    return Wrap(spacing: 12, runSpacing: 12, children: wordWidgets);
  }
}

class _BlinkingCursor extends HookWidget {
  const _BlinkingCursor({super.key}); // ignore: unused_element

  @override
  Widget build(BuildContext context) {
    // Faster, snappier blink (500ms)
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 500),
      initialValue: 1.0, // Start fully visible
    );

    useEffect(() {
      // Repeat back and forth
      controller.repeat(reverse: true);
      return null;
    }, []);

    return FadeTransition(
      opacity: controller,
      child: Container(
        width: 2,
        height: 24, // Full height
        color: AppColors.caret,
      ),
    );
  }
}

class _WordWidget extends HookWidget {
  final String targetWord;
  final String typedWord;
  final int index;
  final bool isActive;
  final bool isPast;

  const _WordWidget({
    required this.targetWord,
    required this.typedWord,
    required this.index,
    required this.isActive,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-scroll logic to keep active word visible
    useEffect(() {
      if (isActive) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Scrollable.ensureVisible(
              context,
              alignment: index == 0
                  ? 0.0
                  : 0.5, // Center the active word vertically, but top align first
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
      return null;
    }, [isActive]); // Only run when active state changes to/from true
    List<InlineSpan> spans = [];

    final len = targetWord.length;
    final typedLen = typedWord.length;

    for (int i = 0; i < len; i++) {
      // Cursor logic start
      if (isActive && i == typedLen) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _BlinkingCursor(key: ValueKey("cursor_$i")),
          ),
        );
      }

      Color color = AppColors.textMain;

      if (i < typedLen) {
        if (typedWord[i] == targetWord[i]) {
          color = AppColors.textActive; // Correct
        } else {
          color = AppColors.error; // Incorrect
        }
      } else if (isPast) {
        // Missed character
        color = AppColors.error.withValues(alpha: 0.5);
      }

      spans.add(
        TextSpan(
          text: targetWord[i],
          style: TextStyle(
            color: color,
            fontSize: 24,
            height: 1.5, // Match parent relaxed height
            letterSpacing: 0,
          ),
        ),
      );
    }

    // Trailing cursor logic
    if (isActive && typedLen >= len) {
      if (typedLen > len) {
        String extra = typedWord.substring(len);
        spans.add(
          TextSpan(
            text: extra,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 24,
              height: 1.5, // Match parent relaxed height
              letterSpacing: 0,
            ),
          ),
        );
      }

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _BlinkingCursor(key: ValueKey("cursor_trail_$typedLen")),
        ),
      );
    } // End cursor logic

    return Text.rich(
      TextSpan(
        children: spans,
        style: const TextStyle(
          fontSize: 24,
          height: 1.5, // Relaxed height prevents baseline shifts
        ),
      ),
    );
  }
}
