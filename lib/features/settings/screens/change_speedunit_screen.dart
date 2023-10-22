import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/features/settings/screens/settings_page.dart';

class ChangeSpeedUnitScreen extends StatefulWidget {
  const ChangeSpeedUnitScreen({super.key});

  @override
  State<ChangeSpeedUnitScreen> createState() => _ChangeSpeedUnitScreenState();
}

class _ChangeSpeedUnitScreenState extends State<ChangeSpeedUnitScreen> {
  List<Unit> speedUnits = [
    Unit(key: 'mph', value: 'Miles Per Hour'),
    Unit(key: 'mps', value: 'Meters Per Second'),
    Unit(key: 'kmph', value: 'Kilometers Per Hour'),
  ];
  @override
  Widget build(BuildContext context) {
    var settingsProvider = Provider.of<UnitsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Change Speed Unit"),
        centerTitle: true,
      ),
      body: Column(children: [
        RadioListTile(
            toggleable: true,
            title: Text(
              "Miles Per Hour",
              style: context.textStyles.mRegular(),
            ),
            activeColor: Theme.of(context).colorScheme.onPrimary,
            value: "mph",
            groupValue: settingsProvider.settings.speedUnit,
            onChanged: (value) {
              settingsProvider.settings.speedUnit =
                  value ?? settingsProvider.settings.speedUnit;
              settingsProvider.setAllUnits(settingsProvider.settings);
            }),
        RadioListTile(
            toggleable: true,
            title: Text(
              "Meters Per Second",
              style: context.textStyles.mRegular(),
            ),
            activeColor: Theme.of(context).colorScheme.onPrimary,
            value: "mps",
            groupValue: settingsProvider.settings.speedUnit,
            onChanged: (value) {
              settingsProvider.settings.speedUnit =
                  value ?? settingsProvider.settings.speedUnit;
              settingsProvider.setAllUnits(settingsProvider.settings);
            }),
        RadioListTile(
            toggleable: true,
            title: Text(
              "Kilometers Per Hour",
              style: context.textStyles.mRegular(),
            ),
            activeColor: Theme.of(context).colorScheme.onPrimary,
            value: "kmph",
            groupValue: settingsProvider.settings.speedUnit,
            onChanged: (value) {
              settingsProvider.settings.speedUnit =
                  value ?? settingsProvider.settings.speedUnit;
              settingsProvider.setAllUnits(settingsProvider.settings);
            }),
      ]),
    );
  }
}
