// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/components/textfield.dart';
import 'package:speedometer/core/models/UserModel.dart';
import 'package:speedometer/core/providers/user_provider.dart';
import 'package:speedometer/core/services/auth_services.dart';
import 'package:speedometer/core/services/firebase_services.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/main_navigation_screen.dart';

class SignUpScreen extends StatefulWidget {
  final Function(bool) onFocusChanged;

  const SignUpScreen({super.key, required this.onFocusChanged});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _userNameFocus = FocusNode();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obscure = true;
  File? image;
  bool loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // InkWell(
          //   onTap: () {
          //     showModalBottomSheet(
          //       context: context,
          //       builder: (context) {
          //         return Container(
          //           height: 110.h,
          //           padding: EdgeInsets.symmetric(
          //             horizontal: 20.sp,
          //           ),
          //           child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 TextButton.icon(
          //                   onPressed: () async {
          //                     Navigator.of(context).pop();
          //                     var pickImage = await ImagePicker()
          //                         .pickImage(source: ImageSource.gallery);
          //                     image = File(pickImage!.path);
          //                     setState(() {});
          //                   },
          //                   label: Text("Selecione na Galeria"),
          //                   icon: Icon(Icons.photo_library_outlined),
          //                 ),
          //                 TextButton.icon(
          //                   onPressed: () async {
          //                     Navigator.of(context).pop();

          //                     var pickImage = await ImagePicker()
          //                         .pickImage(source: ImageSource.camera);
          //                     image = File(pickImage!.path);
          //                     setState(() {});
          //                   },
          //                   label: Text("Tirar uma foto"),
          //                   icon: Icon(Icons.camera),
          //                 ),
          //               ]),
          //         );
          //       },
          //     );
          //   },
          //   child: CircleAvatar(
          //     radius: 50.r,
          //     child: image == null
          //         ? Icon(
          //             Icons.camera_alt,
          //             size: 60.sp,
          //           )
          //         : const SizedBox(),
          //     backgroundImage: image != null ? FileImage(image!) : null,
          //   ),
          // ),

          // SizedBox(
          //   height: _emailFocus.hasFocus ||
          //           _passwordFocus.hasFocus ||
          //           _userNameFocus.hasFocus
          //       ? 0
          //       : 20.h,
          // ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                    controller: _userNameController,
                    focusNode: _userNameFocus,
                    label: '@Username',
                    onFocusChanged: widget.onFocusChanged),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    label: 'Email',
                    onFocusChanged: widget.onFocusChanged),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    label: 'Password',
                    obscure: true,
                    onFocusChanged: widget.onFocusChanged),
              ],
            ),
          ),
          //
          SizedBox(
            height: 15.h,
          ),
          loading
              ? const CircularProgressIndicator(
                  color: Color(0xff0BDD64),
                )
              : ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                      });
                      var signupUser = await AuthService()
                          .registerWithEmailAndPassword(
                              _emailController.text,
                              _passwordController.text,
                              _userNameController.text,
                              context);
                      if (signupUser != null) {
                        userProvider.setPrefEmail(_emailController.text);
                        userProvider.setPrefUserId(signupUser.uid);
                        UserModel? user =
                            await FirebaseServices().singleUser(signupUser.uid);
                        userProvider.setUser(user!);
                        userProvider.userIn();

                        setState(() {
                          loading = false;
                        });
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const MainNavigationScreen(),
                        )); 
                      } else {
                        setState(() {
                          loading = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(345.w, 50.h),
                      backgroundColor: const Color(0xff0BDD64),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r))),
                  child: Text(
                    'Sign up',
                    style: context.textStyles.mThick(),
                  ),
                ),
          SizedBox(
            height: 20.h,
          ),
        ],
      ),
    );
  }
}
