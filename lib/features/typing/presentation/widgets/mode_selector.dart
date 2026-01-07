import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:typespeed/common/constants/app_colors.dart';
import 'package:typespeed/features/typing/domain/test_models.dart';
import 'package:typespeed/features/typing/providers/typing_session_provider.dart';

class ModeSelector extends ConsumerWidget {
  final TestSettings currentSettings;

  const ModeSelector({super.key, required this.currentSettings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const .symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.subBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeButton(
            label: 'Time',
            isActive: currentSettings.mode == TestMode.time,
            icon: HugeIcons.strokeRoundedTime01,
            onTap: () => ref
                .read(typingSessionProvider.notifier)
                .updateSettings(
                  currentSettings.copyWith(
                    mode: TestMode.time,
                    targetAmount: 30,
                  ),
                ),
          ),
          const SizedBox(width: 16),
          _ModeButton(
            label: 'Words',
            isActive: currentSettings.mode == TestMode.words,
            icon: HugeIcons.strokeRoundedText,
            onTap: () => ref
                .read(typingSessionProvider.notifier)
                .updateSettings(
                  currentSettings.copyWith(
                    mode: TestMode.words,
                    targetAmount: 25,
                  ),
                ),
          ),
          Container(
            height: 20,
            width: 1,
            color: AppColors.textMain,
            margin: const .symmetric(horizontal: 16),
          ),
          // Sub-options depend on mode
          if (currentSettings.mode == TestMode.time) ...[
            _OptionButton(
              val: 15,
              current: currentSettings.targetAmount,
              onTap: (v) => _updateAmount(ref, v),
            ),
            _OptionButton(
              val: 30,
              current: currentSettings.targetAmount,
              onTap: (v) => _updateAmount(ref, v),
            ),
            _OptionButton(
              val: 60,
              current: currentSettings.targetAmount,
              onTap: (v) => _updateAmount(ref, v),
            ),
          ] else ...[
            _OptionButton(
              val: 10,
              current: currentSettings.targetAmount,
              onTap: (v) => _updateAmount(ref, v),
            ),
            _OptionButton(
              val: 25,
              current: currentSettings.targetAmount,
              onTap: (v) => _updateAmount(ref, v),
            ),
            _OptionButton(
              val: 50,
              current: currentSettings.targetAmount,
              onTap: (v) => _updateAmount(ref, v),
            ),
          ],
        ],
      ),
    );
  }

  void _updateAmount(WidgetRef ref, int amount) {
    final settings = ref.read(typingSessionProvider).settings;
    ref
        .read(typingSessionProvider.notifier)
        .updateSettings(settings.copyWith(targetAmount: amount));
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final dynamic icon;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isActive,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          HugeIcon(
            icon: icon,
            color: isActive ? AppColors.primary : AppColors.textMain,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final int val;
  final int current;
  final Function(int) onTap;

  const _OptionButton({
    required this.val,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = val == current;
    return Padding(
      padding: const .symmetric(horizontal: 8),
      child: InkWell(
        onTap: () => onTap(val),
        child: Text(
          val.toString(),
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textMain,
          ),
        ),
      ),
    );
  }
}
