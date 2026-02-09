import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/router.dart';
import 'core/constants/app_constants.dart';

void main() {
  runApp(const ProviderScope(child: MosquePoolApp()));
}

class MosquePoolApp extends StatelessWidget {
  const MosquePoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: routerConfig,
    );
  }
}
