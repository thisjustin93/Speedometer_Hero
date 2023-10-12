import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:clipboard/clipboard.dart';
import 'package:speedometer/core/utils/app_snackbar.dart';

shareBottomSheet(
    BuildContext context, PedometerSession pedometerSession, File file) {
  return showCupertinoModalPopup(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: Row(
        children: [
          Icon(
            Icons.text_snippet_outlined,
            size: 35.sp,
          ),
          SizedBox(
            width: 10.w,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pedometerSession.sessionTitle,
                  style: AppTextStyles().mThick.copyWith(color: Colors.black),
                ),
                Text(
                    'Text Document   ${(file.lengthSync() / 1000).toStringAsFixed(2)} KB')
              ],
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.cancel))
        ],
      ),
      message: Container(
        height: 400.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/messages_logo.png',
                    height: 50.h,
                    width: 50.h,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    'Messages',
                    style: AppTextStyles().sRegular.copyWith(fontSize: 10.sp),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 25.h,
            ),
            Container(
              height: 145.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async {
                      Map<String, dynamic> jsonData =
                          jsonDecode(file.readAsStringSync());
                      print(jsonData);
                      String textToCopy = jsonData.toString();
                      await FlutterClipboard.copy(textToCopy);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.sp, vertical: 5.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Copy',
                            style: AppTextStyles()
                                .mRegular
                                .copyWith(color: Colors.black),
                          ),
                          Icon(Icons.file_copy_outlined),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Color(0xFFF5F6F7),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // final Directory directory =
                      //     await getApplicationDocumentsDirectory();
                      print('1111111111111');
                      final File saveFile =
                          await File('/storage/emulated/0/Download/abc.text')
                              .create(recursive: true);
                      print('a11111111111');
                      print(saveFile.path);
                      print('b11111111111');

                      String text = await file.readAsString();
                      await saveFile.writeAsString(text);
                      print("Done");
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.sp, vertical: 5.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Save to Files',
                            style: AppTextStyles()
                                .mRegular
                                .copyWith(color: Colors.black),
                          ),
                          Icon(Icons.folder_outlined),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Color(0xFFF5F6F7),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'QR scan',
                          style: AppTextStyles()
                              .mRegular
                              .copyWith(color: Colors.black),
                        ),
                        Icon(Icons.qr_code_scanner_outlined),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
