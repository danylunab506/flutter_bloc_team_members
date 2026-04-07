import 'package:flutter/material.dart';

import '/core/theme/app_theme.dart';
import 'core/di/dependency_injection.dart';
import '/router/app_router.dart';

void main() {
  initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Team Members',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: getIt<AppRouter>().router,
    );
  }
}
