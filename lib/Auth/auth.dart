import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:recipe_app/Admin/admin_home_screen.dart';
import 'package:recipe_app/Auth/loginScreen.dart';
import 'package:recipe_app/Pages/MainScreen.dart';
import 'package:recipe_app/Utils/error_messages.dart';

class Auth {
  // SignUp User
  static Future<void> signUpUser(
    String name,
    String email,
    String password,

    BuildContext context,
  ) async {
    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save uid
      final uid = userCred.user!.uid;
      // Save it to firestore
      await FirebaseFirestore.instance.collection("userDetails").doc(uid).set({
        "name": name,
        "email": email,
        "role": "user",
      });
      // // To save user name
      await FirebaseAuth.instance.currentUser!.updateDisplayName(name);
      await FirebaseAuth.instance.currentUser!.reload();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          
          content: Text("Signup Successfully"),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(getFirebaseAuthErrorMessage(e.code)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
      );
    }
  }

  // Login User
  static Future<void> loginUser(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Check user
      User? user = FirebaseAuth.instance.currentUser;
      // now check it is exits in firestore
      if (user != null) {
        DocumentSnapshot doc =
            await FirebaseFirestore.instance
                .collection("userDetails")
                .doc(user.uid)
                .get();
        if (doc.exists) {
          String role = doc['role'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              
              content: Text("Login Successfully"),
            ),
          );
          if (role == "admin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminHomeScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainScreen()),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(getFirebaseAuthErrorMessage(e.code)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
      );
    }
  }

  // Logout
  static Future<void> logoutUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          
          content: Center(
            child: Text("Logout", style: TextStyle(fontSize: 23)),
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
      );
    }
  }
}
