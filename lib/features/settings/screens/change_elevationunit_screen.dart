import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/utils/extensions/context.dart';

class ChangeElevationUnitScreen extends StatefulWidget {
  const ChangeElevationUnitScreen({super.key});

  @override
  State<ChangeElevationUnitScreen> createState() =>
      _ChangeElevationUnitScreenState();
}

class _ChangeElevationUnitScreenState extends State<ChangeElevationUnitScreen> {
  @override
  Widget build(BuildContext context) {
    var settingsProvider = Provider.of<UnitsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Change Elevation Unit"),
        centerTitle: true,
      ),
      body: Column(children: [
        RadioListTile(
            toggleable: true,
            title: Text(
              "Feet",
              style: context.textStyles.mRegular(),
            ),
            activeColor: Theme.of(context).colorScheme.onPrimary,
            value: "ft",
            groupValue: settingsProvider.settings.elevationUnit,
            onChanged: (value) {
              settingsProvider.settings.elevationUnit =
                  value ?? settingsProvider.settings.elevationUnit;
              settingsProvider.setAllUnits(settingsProvider.settings);
            }),
        RadioListTile(
            toggleable: true,
            title: Text(
              "Meters",
              style: context.textStyles.mRegular(),
            ),
            activeColor: Theme.of(context).colorScheme.onPrimary,
            value: "m",
            groupValue: settingsProvider.settings.elevationUnit,
            onChanged: (value) {
              settingsProvider.settings.elevationUnit =
                  value ?? settingsProvider.settings.elevationUnit;
              settingsProvider.setAllUnits(settingsProvider.settings);
            }),
      ]),
    );
  }
}
