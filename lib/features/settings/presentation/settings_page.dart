export 'settings_page.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/settings/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    TextStyle getTextStyle({
      required double fontSize,
      FontWeight? fontWeight,
    }) {
      return theme.textTheme.bodyLarge!.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        inherit: true,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: getTextStyle(fontSize: settings.fontSize),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: getTextStyle(
                fontSize: settings.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListTile(
              title: Text(
                'System',
                style: getTextStyle(fontSize: settings.fontSize),
              ),
              leading: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: settings.themeMode,
                onChanged: (value) => settings.setThemeMode(value!),
              ),
            ),
            ListTile(
              title: Text(
                'Light',
                style: getTextStyle(fontSize: settings.fontSize),
              ),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (value) => settings.setThemeMode(value!),
              ),
            ),
            ListTile(
              title: Text(
                'Dark',
                style: getTextStyle(fontSize: settings.fontSize),
              ),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (value) => settings.setThemeMode(value!),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Font Size',
              style: getTextStyle(
                fontSize: settings.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<double>(
              value: settings.fontSize,
              items: [
                DropdownMenuItem(
                  value: 14.0,
                  child: Text('Small', style: getTextStyle(fontSize: 14.0)),
                ),
                DropdownMenuItem(
                  value: 16.0,
                  child: Text('Medium', style: getTextStyle(fontSize: 16.0)),
                ),
                DropdownMenuItem(
                  value: 20.0,
                  child: Text('Large', style: getTextStyle(fontSize: 20.0)),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  settings.setFontSize(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
