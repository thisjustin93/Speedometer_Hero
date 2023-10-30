import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/services/settigns_db_services.dart';
import 'package:speedometer/core/utils/extensions/context.dart';

class ChangeAppThemeScreen extends StatefulWidget {
  const ChangeAppThemeScreen({super.key});

  @override
  State<ChangeAppThemeScreen> createState() => _ChangeAppThemeScreenState();
}

class _ChangeAppThemeScreenState extends State<ChangeAppThemeScreen> {
  @override
  Widget build(BuildContext context) {
    var settingsProvider = Provider.of<UnitsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Change Theme"),
        centerTitle: true,
      ),
      body: Column(children: [
        RadioListTile.adaptive(
            toggleable: true,
            title: Text(
              "Dark Theme",
              style: context.textStyles.mRegular(),
            ),
            // activeColor: Theme.of(context).colorScheme.onPrimary,
            value: true,
            fillColor: MaterialStatePropertyAll(
                Theme.of(context).colorScheme.onPrimary),
            groupValue: settingsProvider.settings.darkTheme,
            onChanged: (toDark) async {
              settingsProvider.settings.darkTheme = true;
              settingsProvider.setAllUnits(settingsProvider.settings);
              await HiveSettingsDB().updateSettings(settingsProvider.settings);
            }),
        RadioListTile.adaptive(
            toggleable: true,
            title: Text(
              "Light Theme",
              style: context.textStyles.mRegular(),
            ),
            value: false,
            fillColor: MaterialStatePropertyAll(
                Theme.of(context).colorScheme.onPrimary),
            // activeColor: Theme.of(context).colorScheme.onPrimary,
            groupValue: settingsProvider.settings.darkTheme,
            onChanged: (toLight) async {
              settingsProvider.settings.darkTheme = false;
              settingsProvider.setAllUnits(settingsProvider.settings);
              await HiveSettingsDB().updateSettings(settingsProvider.settings);
            }),
        RadioListTile.adaptive(
            toggleable: true,
            title: Text(
              "System Theme",
              style: context.textStyles.mRegular(),
            ),
            value: null,
            fillColor: MaterialStatePropertyAll(
                Theme.of(context).colorScheme.onPrimary),
            // activeColor: Theme.of(context).colorScheme.onPrimary,
            groupValue: settingsProvider.settings.darkTheme,
            onChanged: (toNull) async {
              settingsProvider.settings.darkTheme = null;
              settingsProvider.setAllUnits(settingsProvider.settings);
              await HiveSettingsDB().updateSettings(settingsProvider.settings);
            }),
      ]),
    );
  }
}
