import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:speedometer/core/components/textfield.dart';
import 'package:speedometer/core/models/UserModel.dart';
import 'package:speedometer/core/providers/user_provider.dart';
import 'package:speedometer/core/services/auth_services.dart';
import 'package:speedometer/core/services/firebase_services.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/features/Auth/forgot_password_screen.dart';
import 'package:speedometer/main_navigation_screen.dart';

class SignInScreen extends StatefulWidget {
  final Function(bool) onFocusChanged;
  const SignInScreen({super.key, required this.onFocusChanged});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obscure = true;
  bool loading = false;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
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
          // SizedBox(
          //   height: 30.h,
          // ),
          // const CustomDivider(),
          SizedBox(
            height: 15.h,
          ),
          // SizedBox(
          //   height: 15.h,
          // ),
          loading
              ? CircularProgressIndicator(
                  color: Color(0xff0BDD64),
                )
              : ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                      });
                      var userDoc =
                          await AuthService().signInWithEmailAndPassword(
                        _emailController.text,
                        _passwordController.text,
                      );
                      if (userDoc != null) {
                        userProvider.setPrefEmail(_emailController.text);
                        userProvider.setPrefUserId(userDoc.uid);
                        UserModel? user =
                            await FirebaseServices().singleUser(userDoc.uid);
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            width: 300.w,
                            backgroundColor: const Color(0xff0BDD64),
                            content: Center(
                              child: Text("E-mail and Password don't match",
                                  style: context.textStyles.mRegular()),
                            ),
                          ),
                        );
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
                    'Sign in',
                    style: context.textStyles.mThick(),
                  ),
                ),
          SizedBox(
            height: 10.h,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ForgotPasswordScreen(),
              ));
            },
            child:
                Text('Forgot Password?', style: context.textStyles.mRegular()),
          ),
        ],
      ),
    );
  }
}

Future getImage(String url) async {
  final response = await http.get(Uri.parse(url));
  final directory = await getExternalStorageDirectory();
  final imagePath = '${directory!.path}/profilepic.jpg';
  final imageFile = File(imagePath);
  await imageFile.writeAsBytes(response.bodyBytes);
  return imageFile;
}
