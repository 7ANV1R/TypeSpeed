import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:typespeed/common/constants/app_colors.dart';

class RollingCounter extends StatelessWidget {
  final String text;

  const RollingCounter({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: .center,
      children: text.characters.map((char) {
        return AnimatedSwitcher(
          duration: 200.ms,
          transitionBuilder: (child, animation) {
            final isCurrent = (child.key as ValueKey<String>).value == char;
            final offset = isCurrent
                ? Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation)
                : Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(animation);

            return SlideTransition(
              position: offset,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Text(
            char,
            key: ValueKey(char),
            style: const TextStyle(
              fontSize: 24,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }
}
