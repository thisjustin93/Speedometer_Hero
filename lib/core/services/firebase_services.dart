// import 'package:speedometer/core/models/UserModel.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class FirebaseServices {
//   // creating a new user
//   Future<UserModel> creatUser(
//       String uid, String username, String email, String password) async {
//     var data = FirebaseFirestore.instance.collection('users').doc(uid);
//     username = username.trim();
//     final user = UserModel(
//         userId: uid,
//         userName: username,
//         userEmail: email,
//         isUserSubscribed: false,);
//     final json = user.toMap();
//     await data.set(json);
//     return user;
//   }
//     // get user data
//   Future<UserModel?> singleUser(String uid) async {
//     try {
//       final userDoc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       print(userDoc.data());
//       UserModel user = UserModel.fromMap(userDoc.data()!);

//       return user;
//     } catch (e) {
//       print(e.toString());
//     }
//   }
//    // Update User

//   Future<UserModel?> updateUser(UserModel user) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.userId)
//           .update(user.toMap());

//       return user;
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }
// }
