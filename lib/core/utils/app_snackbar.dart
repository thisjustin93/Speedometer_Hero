import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speedometer/core/utils/extensions/context.dart';

SnackBar errorSnackbar({
  required String content,
  required BuildContext context,
}) {
  return SnackBar(
    content: Text(
      content,
      style: context.textStyles.sRegular.copyWith(color: Colors.white),
    ),
    backgroundColor: Colors.red,
    behavior: SnackBarBehavior.floating,
    dismissDirection: DismissDirection.none,
    margin: kIsWeb
        ? EdgeInsets.only(
            bottom: context.deviceSize.height - 50,
            right: context.deviceSize.width * 0.35,
            left: context.deviceSize.width * 0.35)
        : null,
  );
}

SnackBar successSnackbar({
  required String content,
  required BuildContext context,
}) {
  return SnackBar(
    content: Text(
      content,
      style: context.textStyles.sRegular.copyWith(color: Colors.white),
    ),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    dismissDirection: DismissDirection.none,
    margin: EdgeInsets.only(
        bottom: context.deviceSize.height - 50,
        right: context.deviceSize.width * 0.35,
        left: context.deviceSize.width * 0.35),
  );
}

void showErrorMessage(context, SnackBar snackBar) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
