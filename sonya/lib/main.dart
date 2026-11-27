import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'providers/business_data_provider.dart';
import 'screens/main_shell.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appProvider = AppProvider();
  await appProvider.load();

  runApp(MurghasBusinessApp(appProvider: appProvider));
}

class MurghasBusinessApp extends StatelessWidget {
  final AppProvider appProvider;
  const MurghasBusinessApp({super.key, required this.appProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider(
          create: (_) => BusinessDataProvider()..loadAll(),
        ),
      ],
      child: Consumer<AppProvider>(
        builder: (context, app, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'मुरघास व्यवसाय व्यवस्थापन',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: app.themeMode,
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
