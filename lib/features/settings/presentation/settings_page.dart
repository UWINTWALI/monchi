export 'settings_page.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/settings/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('System'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: settings.themeMode,
                onChanged: (value) => settings.setThemeMode(value!),
              ),
            ),
            ListTile(
              title: const Text('Light'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (value) => settings.setThemeMode(value!),
              ),
            ),
            ListTile(
              title: const Text('Dark'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (value) => settings.setThemeMode(value!),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Font Size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<double>(
              value: settings.fontSize,
              items: const [
                DropdownMenuItem(value: 14.0, child: Text('Small')),
                DropdownMenuItem(value: 16.0, child: Text('Medium')),
                DropdownMenuItem(value: 20.0, child: Text('Large')),
              ],
              onChanged: (value) => settings.setFontSize(value!),
            ),
          ],
        ),
      ),
    );
  }
}
