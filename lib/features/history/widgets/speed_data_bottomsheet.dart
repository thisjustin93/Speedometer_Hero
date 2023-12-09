import 'dart:convert';
import 'dart:io';
import 'package:screenshot/screenshot.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/models/SettingsModel.dart';
import 'package:speedometer/core/providers/subscription_provider.dart';
import 'package:speedometer/core/utils/convert_speed.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/features/history/widgets/share_bottomsheet.dart';

speedDataBottomSheet(BuildContext context, List<String> timestamp,
    List<double> speed, SettingsModel settings, PedometerSession session) {
  return showCupertinoModalBottomSheet(
    expand: true,
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Material(
          child: CupertinoPageScaffold(
            backgroundColor: Theme.of(context).primaryColor,
            navigationBar: CupertinoNavigationBar(
              backgroundColor: Theme.of(context).primaryColor,
              leading: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              middle: Text(
                "Speed Data",
                style: context.textStyles.mThick(),
              ),
              trailing: IconButton(
                onPressed: () async {
                  shareBottomSheet(context, session);
                },
                icon: Icon(
                  Icons.file_upload_outlined,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            child: Container(
                padding: EdgeInsets.only(left: 20.w),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: speed.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 30.h,
                      margin: EdgeInsets.only(bottom: 15.h),
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              timestamp[index],
                              style: context.textStyles.mThick(),
                            ),
                          ),
                          Text(
                            convertSpeed(speed[index], settings.speedUnit)
                                .toStringAsFixed(1),
                            style: context.textStyles.mRegular(),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Text(
                            settings.speedUnit,
                            style: context.textStyles.mRegular(),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                        ],
                      ),
                    );
                  },
                )),
          ),
        );
      },
    ),
  );
}
