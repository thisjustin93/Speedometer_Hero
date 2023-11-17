import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/providers/user_provider.dart';
import 'package:speedometer/core/utils/extensions/context.dart';

class CustomTextField extends StatefulWidget {
  final Function(bool) onFocusChanged;
  final FocusNode focusNode;
  final String label;
  bool obscure;
  final TextEditingController controller;
  CustomTextField(
      {super.key,
      required this.focusNode,
      required this.label,
      required this.controller,
      this.obscure = false,
      required this.onFocusChanged});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    return FractionallySizedBox(
      widthFactor: 1,
      child: TextFormField(
        validator: widget.label == '@Username'
            ? (value) => value == null || value.isEmpty
                ? "Username can't be empty"
                : null
            : widget.label == 'Password'
                ? (value) => value!.length < 6
                    ? "password can't be less than 6 characters"
                    : null
                : (value) => value!.isEmpty ? "Email can't be empty" : null,
        inputFormatters:
            widget.label == '@Username' || widget.label == '@Username '
                ? [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty || newValue.text[0] != "@") {
                        return TextEditingValue(
                          text: "@${newValue.text}",
                          selection: newValue.selection.copyWith(
                            baseOffset: newValue.selection.baseOffset + 1,
                            extentOffset: newValue.selection.extentOffset + 1,
                          ),
                        );
                      } else {
                        return newValue;
                      }
                    }),
                  ]
                : null,
        controller: widget.controller,
        focusNode: widget.focusNode,
        style: context.textStyles.mRegular().copyWith(color: Colors.black),
        obscureText: widget.obscure,
        cursorColor: Colors.grey,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 20.w),
          filled: true,
          fillColor: Colors.white,
          hintText: widget.label,
          hintStyle: TextStyle(color: Colors.grey),
          suffixIcon: widget.label == 'Password'
              ? IconButton(
                  icon: widget.obscure
                      ? Icon(
                          Icons.visibility_off_outlined,
                          color: Colors.grey,
                          size: 20.sp,
                        )
                      : Icon(
                          Icons.visibility_outlined,
                          color: Colors.grey,
                          size: 20.sp,
                        ),
                  onPressed: () {
                    setState(() {
                      widget.obscure = !widget.obscure;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.r),
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
        onEditingComplete: () {
          setState(() {
            widget.focusNode.unfocus();
          });
          widget.onFocusChanged(false);
        },
        onFieldSubmitted: (value) {
          setState(() {
            widget.focusNode.unfocus();
          });
          widget.onFocusChanged(false);
        },
        onTapOutside: (value) {
          widget.focusNode.unfocus();
          widget.onFocusChanged(false);
        },
        onTap: () {
          widget.onFocusChanged(true);
        },
      ),
    );
  }
}
