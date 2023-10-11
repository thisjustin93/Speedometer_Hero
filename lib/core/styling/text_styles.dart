import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  final TextStyle mRegular = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    fontSize: 16.sp,
    decoration: TextDecoration.none,
    letterSpacing: 0,
  );

  final TextStyle mThick = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    fontSize: 16.sp,
    decoration: TextDecoration.none,
    letterSpacing: 0,
  );

  final TextStyle sRegular = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    fontSize: 12.sp,
    decoration: TextDecoration.none,
    letterSpacing: 0,
  );

  final TextStyle sThick = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    fontSize: 12.sp,
    decoration: TextDecoration.none,
    letterSpacing: 0,
  );

  final lThin = GoogleFonts.nunito(
    fontWeight: FontWeight.w300,
    fontStyle: FontStyle.normal,
    fontSize: 20.sp,
    decoration: TextDecoration.none,
    letterSpacing: 0,
  );
  final lMedium = GoogleFonts.nunito(
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
    fontSize: 28.sp,
    decoration: TextDecoration.none,
    letterSpacing: 0,
  );

  final lRegular = GoogleFonts.raleway(
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
    fontSize: 40.sp,
    decoration: TextDecoration.none,
    letterSpacing: 0,
  );

  final lThick = GoogleFonts.raleway(
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.normal,
    fontSize: 40.sp,
    decoration: TextDecoration.none,
    letterSpacing: 0,
  );
}
