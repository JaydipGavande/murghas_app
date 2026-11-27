import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final s = app.strings;

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('डार्क मोड'),
              subtitle: const Text('लाईट आणि डार्क थीम बदला'),
              value: app.profile.isDarkMode,
              onChanged: app.toggleDarkMode,
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.translate),
              title: Text('भाषा'),
              subtitle: Text('मराठी'),
            ),
          ),
        ],
      ),
    );
  }
}
