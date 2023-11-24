// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:speedometer/core/utils/extensions/context.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   TextEditingController _emailController = TextEditingController();
//   FocusNode _emailFocus = FocusNode();
//   final auth = FirebaseAuth.instance;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 50.h,
//       ),
//       body: Container(
//         padding: EdgeInsets.symmetric(horizontal: 15.sp),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               height: 5.sp,
//             ),
//             Text(
//               'Encontre Sua Conta',
//               style: context.textStyles.lRegular(),
//             ),
//             SizedBox(
//               height: 10.sp,
//             ),
//             Text(
//               'Insira o seu endereço de email',
//               style: context.textStyles.lRegular(),
//             ),
//             SizedBox(
//               height: 25.sp,
//             ),
//             SizedBox(
//               height: 60.h,
//               child: TextField(
//                 controller: _emailController,
//                 focusNode: _emailFocus,
//                 style: context.textStyles.mRegular(),
//                 cursorColor: Colors.grey,
//                 decoration: InputDecoration(
//                   contentPadding: EdgeInsets.only(left: 15.w),
//                   filled: true,
//                   labelText: 'E-mail address',
//                   labelStyle: TextStyle(color: Colors.grey),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                     borderSide: BorderSide(color: Colors.transparent),
//                   ),
//                 ),
//                 onEditingComplete: () {
//                   _emailFocus.unfocus();
//                 },
//                 onSubmitted: (value) {
//                   _emailFocus.unfocus();
//                 },
//                 onTapOutside: (event) {
//                   _emailFocus.unfocus();
//                 },
//               ),
//             ),
//             SizedBox(
//               height: 15.sp,
//             ),
//             ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                     fixedSize: Size(double.maxFinite, 47.h),
//                     shape: StadiumBorder(),
//                     backgroundColor: Color(0xff0BDD64),
//                     foregroundColor: Colors.white),
//                 onPressed: () async {
//                   try {
//                     await FirebaseAuth.instance.sendPasswordResetEmail(
//                         email: _emailController.text.trim());
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         behavior: SnackBarBehavior.floating,
//                         width: 300.w,
//                         backgroundColor: const Color(0xff0BDD64),
//                         content: Center(
//                           child: Text(
//                             "Enviamos um e-mail para você recuperar sua senha.",
//                             style: context.textStyles.mRegular(),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                     );
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         behavior: SnackBarBehavior.floating,
//                         width: 300.w,
//                         backgroundColor: const Color(0xff0BDD64),
//                         content: Center(
//                           child: Text(
//                             e.toString(),
//                             style: context.textStyles.mRegular(),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//                 },
//                 child: Text(
//                   "Encontrar conta",
//                   style: context.textStyles.mRegular(),
//                 ))
//           ],
//         ),
//       ),
//     );
//   }
// }
