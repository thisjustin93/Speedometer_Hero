import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            height: 2,
            thickness: 2,
            color: Colors.black,
          ),
        ),
        SizedBox(
          width: 9.w,
        ),
        Text(
          'OR',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 10.sp,
              color: Colors.black),
        ),
        SizedBox(
          width: 9.w,
        ),
        Expanded(
          child: Divider(
            height: 2,
            thickness: 2,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
