import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'shared/providers/theme_provider.dart';
import 'shared/providers/language_provider.dart';
import 'shared/providers/app_state_provider.dart';
import 'shared/data/database/database_helper.dart';
import 'core/routes/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('settings');
  
  // Initialize Database
  await DatabaseHelper.instance.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: const IchitoApp(),
    ),
  );
}

class IchitoApp extends StatelessWidget {
  const IchitoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'ICHITO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: themeProvider.themeMode == AppThemeMode.light ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: themeProvider.backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.accentColor,
          brightness: themeProvider.themeMode == AppThemeMode.light ? Brightness.light : Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: themeProvider.fontFamily,
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
