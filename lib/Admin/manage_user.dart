import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class ManageUser extends StatefulWidget {
  const ManageUser({super.key});

  @override
  State<ManageUser> createState() => _ManageUserState();
}

class _ManageUserState extends State<ManageUser> {
  final users = FirebaseFirestore.instance.collection('userDetails');
  // To Show Dialog
  void _showEditDialog(DocumentSnapshot doc) {
    final nameController = TextEditingController(text: doc['name']);
    final emailController = TextEditingController(text: doc['email']);
    final roleController = TextEditingController(text: doc['role']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Center(child: Text("Edit User")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: roleController,
                decoration: InputDecoration(
                  labelText: "Role",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  updateuserData(
                    doc,
                    nameController.text,
                    emailController.text,
                    roleController.text,
                  );
                },
                child: Text("Update"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Update UserData
  Future<void> updateuserData(
    DocumentSnapshot doc,
    String name,
    String email,
    String role,
  ) async {
    try {
      if (name.isEmpty || email.isEmpty || role.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please fill all field")));
        return;
      }
      final response = await FirebaseFirestore.instance
          .collection('userDetails')
          .doc(doc.id)
          .update({'name': name, 'email': email, 'role': role});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("UserData Updated")));
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
    }
  }

  // Delete User
  Future<void> deleteUser(DocumentSnapshot doc) async {
    try {
      final response =
          await FirebaseFirestore.instance
              .collection('userDetails')
              .doc(doc.id)
              .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("User Deleted")),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Users", style: TextStyle(fontSize: 26)),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          SizedBox(height: 15),
          Center(child: Text("All Users", style: TextStyle(fontSize: 30))),
          SizedBox(height: 15),
          Expanded(
            child: StreamBuilder(
              stream: users.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text("Something went wromg");
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    return Card(
                      child: ListTile(
                        leading: Text(
                          "${index + 1}",
                          style: TextStyle(fontSize: 20),
                        ),
                        title: Text(
                          data['name'],
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          data['email'],
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              data['role'],
                              style: TextStyle(
                                fontSize: 17,
                                color:
                                    data['role'] == 'admin'
                                        ? Colors.red[200]
                                        : Colors.green[200],
                              ),
                            ),
                            SizedBox(width: 20),
                            IconButton(
                              onPressed: () {
                                _showEditDialog(data);
                              },
                              icon: Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () {
                                deleteUser(data);
                              },
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
