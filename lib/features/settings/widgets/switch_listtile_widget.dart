import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/services/settigns_db_services.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/extensions/context.dart';

class SwithListTile extends StatelessWidget {
  String type;

  SwithListTile({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    var settingProvider = Provider.of<UnitsProvider>(context);

    return Container(
      height: 50.h,
      padding: EdgeInsets.only(top: 5.h),
      decoration: BoxDecoration(
          border: type == 'Dark Theme'
              ? null
              : Border(bottom: BorderSide(color: Colors.grey))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            type,
            style: context.textStyles.mRegular(),
          ),
          CupertinoSwitch(
            value: type == "Show Compass"
                ? settingProvider.settings.showCompass
                : type == "Show Elevation"
                    ? settingProvider.settings.showElevation
                    : settingProvider.settings.showCityName,
            onChanged: (value) async {
              switch (type) {
                case "Show Compass":
                  settingProvider.settings.showCompass =
                      !settingProvider.settings.showCompass;
                  settingProvider.setAllUnits(settingProvider.settings);
                  break;
                case "Show Elevation":
                  settingProvider.settings.showElevation =
                      !settingProvider.settings.showElevation;
                  settingProvider.setAllUnits(settingProvider.settings);
                  break;
                case "Show City Name":
                  settingProvider.settings.showCityName =
                      !settingProvider.settings.showCityName;
                  settingProvider.setAllUnits(settingProvider.settings);
                  break;
                // case "Dark Theme":
                //   settingProvider.settings.darkTheme =
                //       !settingProvider.settings.darkTheme;
                //   settingProvider.setAllUnits(settingProvider.settings);
                //   break;
                default:
              }
              await HiveSettingsDB().updateSettings(settingProvider.settings);
            },
          ),
        ],
      ),
    );
  }
}
