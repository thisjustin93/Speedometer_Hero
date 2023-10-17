import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  final BuildContext context;
  AppTextStyles(this.context);
  TextStyle mRegular() {
    return GoogleFonts.poppins(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      fontSize: 14.sp,
      decoration: TextDecoration.none,
      letterSpacing: 0,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }

  TextStyle mThick() {
    return GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
      fontSize: 16.sp,
      decoration: TextDecoration.none,
      letterSpacing: 0,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }

  TextStyle sRegular() {
    return GoogleFonts.poppins(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      fontSize: 12.sp,
      decoration: TextDecoration.none,
      letterSpacing: 0,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }

  TextStyle sThick() {
    return GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
      fontSize: 12.sp,
      decoration: TextDecoration.none,
      letterSpacing: 0,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }

  TextStyle lThin() {
    return GoogleFonts.nunito(
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.normal,
      fontSize: 20.sp,
      decoration: TextDecoration.none,
      letterSpacing: 0,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }

  TextStyle lMedium() {
    return GoogleFonts.nunito(
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      fontSize: 28.sp,
      decoration: TextDecoration.none,
      letterSpacing: 0,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }

  TextStyle lRegular() {
    return GoogleFonts.raleway(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      fontSize: 40.sp,
      decoration: TextDecoration.none,
      letterSpacing: 0,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }

  TextStyle lThick() {
    return GoogleFonts.raleway(
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.normal,
      fontSize: 40.sp,
      decoration: TextDecoration.none,
      letterSpacing: 0,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }
}
