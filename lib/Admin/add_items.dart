import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // For Image
  File? _imageFile;
  final picker = ImagePicker();
  String? uploadedImageUrl;

  Future<void> _pickImage() async {
    // Taking Image from image
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // Ab Cloudinary me upload karo
      await _uploadToCloudinary(_imageFile!);
    }
  }

  Future<void> _uploadToCloudinary(File imageFile) async {
    String cloudName = "dq6aojv0c";
    String uploadPresent = "recipe-preset";

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );
    final request =
        http.MultipartRequest("POST", url)
          ..fields['upload_preset'] = uploadPresent
          ..files.add(
            await http.MultipartFile.fromPath("file", imageFile.path),
          );

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);
    if (response.statusCode == 200) {
      final data = json.decode(responseData.body);
      setState(() {
        uploadedImageUrl = data["secure_url"]; // Cloudinary image ka URL
      });
      print("Uploaded: $uploadedImageUrl");
    } else {
      print("Upload failed: ${responseData.body}");
    }
  }

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _calController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();

  // Category list
  String? _selectedCategory;
  final List<String> _categories = ["Breakfast", "Lunch", "Dinner","Snack","Dessert"];

  // Ingredients
  List<Map<String, TextEditingController>> ingredients = [];

  @override
  void initState() {
    super.initState();
    addIngredient(); // default ek ingredient row
  }

  void addIngredient() {
    ingredients.add({
      "name": TextEditingController(),
      "amount": TextEditingController(),
    });
    setState(() {});
  }

  void removeIngredient(int index) {
    ingredients.removeAt(index);
    setState(() {});
  }

  void saveItem() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "name": _nameController.text.trim(),
        "category": _selectedCategory,
        "cal": int.tryParse(_calController.text) ?? 0,
        "time": int.tryParse(_timeController.text) ?? 0,
        "rating": _ratingController.text.trim(),
        "review": int.tryParse(_reviewController.text) ?? 0,
        "image": uploadedImageUrl ?? "", // yaha Cloudinary wali URL save hogi
        "ingredientsName":
            ingredients.map((e) => e["name"]!.text.trim()).toList(),
        "ingredientsAmount":
            ingredients.map((e) => e["amount"]!.text.trim()).toList(),
        "createdAt": FieldValue.serverTimestamp(), // sorting ke liye helpful
      };

      try {
        await FirebaseFirestore.instance
            .collection("Complete-Recipe-App")
            .add(data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item saved successfully")),
        );

        // form clear karne ke liye
        _formKey.currentState!.reset();
        _nameController.clear();
        _calController.clear();
        _timeController.clear();
        _ratingController.clear();
        _reviewController.clear();
        _imageFile = null;
        uploadedImageUrl = null;
        ingredients.clear();
        addIngredient();
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          "Add Food Item",
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // For Image
              Text("Image", style: TextStyle(fontSize: 25)),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(),
                  ),
                  child:
                      _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : const Icon(Icons.camera_alt_outlined, size: 40),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (val) => val == null ? "Select category" : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _calController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Calories",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _timeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Time (minutes)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _ratingController,
                decoration: InputDecoration(
                  labelText: "Rating",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _reviewController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Reviews",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "Ingredients",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ingredients[index]["name"],
                            decoration: InputDecoration(
                              labelText: "Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: ingredients[index]["amount"],
                            decoration: InputDecoration(
                              labelText: "Amount",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: () => removeIngredient(index),
                        ),
                      ],
                    ),
                  );
                },
              ),

              TextButton.icon(
                onPressed: addIngredient,
                icon: const Icon(Icons.add),
                label: const Text("Add Ingredient"),
              ),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: saveItem,
                child: const Text("Save Item"),
              ),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
