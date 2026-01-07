import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:typespeed/common/constants/app_colors.dart';

class DisqualifiedView extends StatelessWidget {
  const DisqualifiedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          HugeIcon(
            icon: HugeIcons.strokeRoundedAlertCircle,
            color: AppColors.error,
            size: 64,
          ),
          SizedBox(height: 24),
          Text(
            "Cheat Detected!",
            style: TextStyle(
              fontSize: 32,
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Copy-paste is not allowed.",
            style: TextStyle(fontSize: 16, color: AppColors.textMain),
          ),
        ],
      ),
    );
  }
}
