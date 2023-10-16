import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/extensions/context.dart';

shareBottomSheet(BuildContext context, PedometerSession session) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor:
                Provider.of<UnitsProvider>(context).settings.darkTheme
                    ? Theme.of(context).colorScheme.primary
                    : Color.fromARGB(247, 211, 211, 204),
            titlePadding: EdgeInsets.only(top: 10.h),
            contentPadding: EdgeInsets.zero,
            insetPadding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 200.h),
            title: Container(
              alignment: Alignment.center,
              height: 50.sp,
              width: 50.sp,
              decoration: BoxDecoration(
                  color: Color(0xffF82929), shape: BoxShape.circle),
              child: Icon(
                Icons.shopping_cart,
                color: Colors.white,
                size: 30.sp,
              ),
            ),
            content: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Column(
                children: [
                  Text(
                    'Buy the premium version of Speedometer GPSto unlock the full experienceincl. no ads, unlimited activity history & ability to exp data',
                    textAlign: TextAlign.center,
                    style: context.textStyles.mRegular(),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final directory =
                          await getApplicationDocumentsDirectory();
                      final file = File(
                          '${directory.path}/${session.sessionTitle.replaceAll('/', '')}.text');
                      await file.writeAsString(jsonEncode(session.toMap()));
                      Navigator.of(context).pop();
                      Share.shareXFiles([XFile(file.path)]);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffF82929),
                        foregroundColor: Colors.white,
                        fixedSize: Size(300.w, 40.h),
                        shape: StadiumBorder()),
                    child: Text(
                      'Export Data',
                      style: context.textStyles
                          .mThick()
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: context.textStyles.mRegular(),
                      ))
                ],
              ),
            ),
          ));
}
