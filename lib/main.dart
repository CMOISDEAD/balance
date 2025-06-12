import 'package:flutter/material.dart';
import 'package:new_app/components/layout/main_navigation_wrapper.dart';
import 'package:new_app/providers/finance_provider.dart';
import 'package:provider/provider.dart';
import 'package:relative_time/relative_time.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/themes.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FinanceProvider(),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, currentMode, __) {
          return MaterialApp(
            title: 'Money Manager',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: currentMode,
            home: const MainNavigationWrapper(),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              RelativeTimeLocalizations.delegate, // MUY IMPORTANTE
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
