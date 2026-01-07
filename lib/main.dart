import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:typespeed/common/constants/app_colors.dart';
import 'package:typespeed/features/typing/presentation/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TypeSpeed',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.subBackground, // Use surface instead of background
          error: AppColors.error,
          onSurface: AppColors.textMain,
        ),
        fontFamily: 'JetBrains Mono',
        textTheme: const TextTheme().apply(
          fontFamily: 'JetBrains Mono',
          bodyColor: AppColors.textMain,
          displayColor: AppColors.textMain,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
