import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/Auth/auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userName = FirebaseAuth.instance.currentUser!.displayName;
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(fontSize: 30)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            maxRadius: 50,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 65),
          ),
          SizedBox(height: 5),
          Text(userName.toString(), style: TextStyle(fontSize: 28)),
          Text(userEmail.toString(), style: TextStyle(fontSize: 20)),

          SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              Auth.logoutUser(context);
            },
            child: Center(
              child: Text(
                "Logout",
                style: TextStyle(fontSize: 19, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
