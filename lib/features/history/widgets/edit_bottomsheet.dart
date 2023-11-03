import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/pedometer_session_provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/services/hive_database_services.dart';
import 'package:speedometer/core/styling/text_styles.dart';
// import 'package:clipboard/clipboard.dart';
import 'package:speedometer/core/utils/app_snackbar.dart';
import 'package:speedometer/core/utils/extensions/context.dart';

class ActionType {
  final String value;
  final Icon icon;

  ActionType(this.value, this.icon);
}

editBottomSheet(BuildContext context, PedometerSession pedometerSession,
    VoidCallback setstate) {
  List<ActionType> items = [
    ActionType(
        "None",
        const Icon(
          Icons.directions_bike,
          color: Colors.transparent,
          size: 0,
        )),
    ActionType(
        "Cycle",
        const Icon(
          Icons.directions_bike,
          color: Colors.red,
        )),
    ActionType(
        "Run",
        const Icon(
          Icons.directions_run,
          color: Colors.red,
        )),
    ActionType(
        "Motorcycle",
        const Icon(
          Icons.two_wheeler,
          color: Colors.red,
        )),
    ActionType(
        "Car",
        const Icon(
          Icons.directions_car,
          color: Colors.red,
        )),
    ActionType(
        "Train",
        const Icon(
          Icons.directions_train,
          color: Colors.red,
        )),
    ActionType(
        "Plane",
        const Icon(
          Icons.flight,
          color: Colors.red,
        )),
    ActionType(
        "Ship",
        const Icon(
          Icons.sailing,
          color: Colors.red,
        )),
    // ActionType(
    //   "Hike",
    //   const Icon(
    //     Icons.hiking_rounded,
    //     color: Colors.red,
    //   ),
    // ),
    // ActionType(
    //   "Walk",
    //   const Icon(
    //     Icons.directions_walk,
    //     color: Colors.red,
    //   ),
    // ),
    // ActionType(
    //   "Snowboard",
    //   const Icon(
    //     Icons.snowboarding,
    //     color: Colors.red,
    //   ),
    // ),
    // ActionType(
    //   "Sail",
    //   const Icon(
    //     Icons.sailing_outlined,
    //     color: Colors.red,
    //   ),
    // ),
    // ActionType(
    //   "Skateboard",
    //   const Icon(
    //     Icons.skateboarding,
    //     color: Colors.red,
    //   ),
    // ),
    // ActionType(
    //   "Ski",
    //   const Icon(
    //     Icons.downhill_skiing,
    //     color: Colors.red,
    //   ),
    // ),
    // ActionType(
    //   "Crosscountry ski",
    //   const Icon(
    //     Icons.downhill_skiing,
    //     color: Colors.red,
    //   ),
    // ),
  ];
  ActionType selectedActionType = pedometerSession.activityType!.isEmpty
      ? items[0]
      : items.singleWhere((element) =>
          element.value ==
          pedometerSession.activityType); // Set the default selection.

  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  pedometerSession.sessionTitle.contains('/')
      ? null
      : titleController.text = pedometerSession.sessionTitle;
  pedometerSession.note!.isEmpty
      ? null
      : noteController.text = pedometerSession.note!;
  return showCupertinoModalBottomSheet(
    expand: true,
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (_, setState) {
        var settings = Provider.of<UnitsProvider>(context).settings;

        return Material(
          child: CupertinoPageScaffold(
            backgroundColor: Theme.of(context).primaryColor,
            navigationBar: CupertinoNavigationBar(
              backgroundColor: Theme.of(context).primaryColor,
              automaticallyImplyLeading: false,
              middle: Text(
                pedometerSession.sessionTitle.isEmpty
                    ? pedometerSession.startTime.toString()
                    : pedometerSession.sessionTitle,
                style: context.textStyles.mRegular(),
              ),
              trailing: TextButton(
                onPressed: () async {
                  pedometerSession.activityType = selectedActionType.value;
                  pedometerSession.sessionTitle = titleController.text.isEmpty
                      ? pedometerSession.sessionTitle
                      : titleController.text;
                  pedometerSession.note = noteController.text;
                  await HiveDatabaseServices().updateSession(
                      pedometerSession.sessionId, pedometerSession);
                  Provider.of<PedoMeterSessionProvider>(context, listen: false)
                      .setCurrentPedometerSession(pedometerSession);
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Done",
                  style:
                      context.textStyles.mThick().copyWith(color: Colors.red),
                ),
              ),
            ),
            resizeToAvoidBottomInset: true,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 70.h,
                    ),
                    Container(
                      height: 100.h,
                      padding: EdgeInsets.only(left: 25.w),
                      width: MediaQuery.sizeOf(context).width * 0.95,
                      decoration: BoxDecoration(
                          color: settings.darkTheme == null
                              ? MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withRed(35)
                                      .withGreen(35)
                                      .withBlue(35)
                                  : Colors.white
                              : settings.darkTheme!
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withRed(35)
                                      .withGreen(35)
                                      .withBlue(35)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                              color: settings.darkTheme == null
                                  ? MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? Color(0xff1c1c1e)
                                      : Color(0xffc6c6c6)
                                  : settings.darkTheme!
                                      ? Color(0xff1c1c1e)
                                      : Color(0xffc6c6c6))),
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextField(
                            controller: titleController,
                            style: context.textStyles.mRegular(),
                            decoration: InputDecoration(
                                hintText:
                                    pedometerSession.sessionTitle.contains('/')
                                        ? "Title"
                                        : '',
                                hintStyle: context.textStyles.mRegular()),
                            onSubmitted: (value) {
                              pedometerSession.sessionTitle = value;
                            },
                          ),
                          Container(
                            height: 1.h,
                            color: Colors.grey,
                            margin: EdgeInsets.only(bottom: 10.h),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Activity Type",
                                  style: context.textStyles.mRegular()),

                              PullDownButton(
                                itemBuilder: (context) => items
                                    .map((e) => PullDownMenuItem(
                                          onTap: () {
                                            selectedActionType = e;
                                          },
                                          title: e.value,
                                          icon: e.value != "None"
                                              ? e.icon.icon
                                              : null,
                                        ))
                                    .toList(),
                                buttonBuilder: (context, showMenu) => InkWell(
                                  onTap: showMenu,
                                  child: Row(
                                    children: [
                                      selectedActionType.icon,
                                      SizedBox(width: 4.w),
                                      Text(
                                        selectedActionType.value,
                                        style: context.textStyles
                                            .mThick()
                                            .copyWith(color: Colors.red),
                                      ),
                                      SizedBox(
                                        width: 4.w,
                                      ),
                                      Icon(
                                        Icons.unfold_more,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   width: 1.w,
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 35.h,
                    ),
                    Container(
                      height: 180.h,
                      width: double.maxFinite,
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      decoration: BoxDecoration(
                          color: settings.darkTheme == null
                              ? MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withRed(35)
                                      .withGreen(35)
                                  : Colors.white
                              : settings.darkTheme!
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withRed(35)
                                      .withGreen(35)
                                      .withBlue(35)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                              color: settings.darkTheme == null
                                  ? MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? Color(0xff1c1c1e)
                                      : Color(0xffc6c6c6)
                                  : settings.darkTheme!
                                      ? Color(0xff1c1c1e)
                                      : Color(0xffc6c6c6))),
                      child: TextField(
                        controller: noteController,
                        maxLines: 7,
                        maxLength: 200 ,
                        style: context.textStyles.mRegular(),
                        onChanged: (value) {
                          setState(
                            () {},
                          );
                        },
                        decoration: InputDecoration(
                          counter: const SizedBox.shrink(),
                          hintText: 'Note',
                          hintStyle: context.textStyles
                              .mRegular()
                              .copyWith(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                   
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${200 - noteController.text.length} characters left',
                          style: context.textStyles.sRegular(),
                        ),
                      ),
                    // SizedBox(
                    //   height: 200.h,
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  ).then((value) {
    setstate();
  });
}
