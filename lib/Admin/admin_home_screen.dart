import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:recipe_app/Admin/add_items.dart';
import 'package:recipe_app/Admin/item_details_page.dart';
import 'package:recipe_app/Admin/manage_user.dart';
import 'package:recipe_app/Auth/auth.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final userName = FirebaseAuth.instance.currentUser!.displayName;
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  final allItems = FirebaseFirestore.instance.collection("Complete-Recipe-App");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 231, 231),
      appBar: AppBar(
        title: Text("Admin Panel", style: TextStyle(fontSize: 25)),
        backgroundColor: Colors.deepOrange,
      ),
      drawer: drawer(),

      body: Column(children: [SizedBox(height: 10), viewAllItems()]),
    );
  }

  Drawer drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          UserAccountsDrawerHeader(
            accountName: Text(userName.toString()),
            accountEmail: Text(userEmail.toString()),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person_2_outlined, color: Colors.deepOrange),
            ),
            decoration: BoxDecoration(color: Colors.deepOrange),
          ),
          SizedBox(height: 20),
          // Home
          ListTile(
            leading: Icon(Icons.home, size: 27),
            title: Text("Home", style: TextStyle(fontSize: 20)),

            onTap: () {
              Navigator.pop(context);
            },
          ),
          // Add Item
          ListTile(
            leading: Icon(Icons.add, size: 27),
            title: Text("Add Item", style: TextStyle(fontSize: 20)),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddItemScreen()),
              );
            },
          ),
          // Manage Users
          ListTile(
            leading: Icon(Icons.supervised_user_circle, size: 27),
            title: Text("Manage users", style: TextStyle(fontSize: 20)),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ManageUser()),
              );
            },
          ),
          Divider(),
          // Logout
          ListTile(
            leading: Icon(Icons.logout, size: 27),
            title: Text("Logout", style: TextStyle(fontSize: 20)),

            onTap: () {
              Auth.logoutUser(context);
            },
          ),
        ],
      ),
    );
  }

  // View All Item Page
  Expanded viewAllItems() {
    return Expanded(
      child: StreamBuilder(
        stream: allItems.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No items found"));
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GridView.builder(
              itemCount: snapshot.data!.docs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate and pass snapshot
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetailsPage(documentSnapshot: data),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.16,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(data['image']),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                data['name'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Iconsax.flash_1, size: 14),
                                  Text(
                                    "${data['cal']} cal",

                                    style: TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    "  .  ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Icon(Iconsax.clock, size: 14),
                                  SizedBox(width: 3),
                                  Text(
                                    "${data['time']} Min",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_border_outlined,
                                    color: Colors.amberAccent,
                                  ),
                                  Text(
                                    "${data['rating']}/5",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "${data['review']} Reviews",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
