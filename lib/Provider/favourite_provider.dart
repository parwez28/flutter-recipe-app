import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class FavouriteProvider extends ChangeNotifier {
  List<String> _favouriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> get favourites => _favouriteIds;

  FavouriteProvider() {
    loadFavourites();
  }

  void toggleFavourite(DocumentSnapshot product) async {
    String productId = product.id;
    if (_favouriteIds.contains(productId)) {
      _favouriteIds.remove(productId);
      await _removeFavourite(productId); // Remove from favourite
    } else {
      _favouriteIds.add(productId);
      await _addFavourite(productId); // Add to favourite
    }
    notifyListeners();
  }

  // Check if a product is favourited
  bool isExist(DocumentSnapshot prouct) {
    return _favouriteIds.contains(prouct.id);
  }

  // add favourites to firestore
  Future<void> _addFavourite(String productId) async {
    try {
      await _firestore.collection("userFavourite").doc(productId).set({
        'isFavourite':
            true, // Create the userFavourite collection and add item as favourites inf firestore
      });
    } catch (e) {
      print(e);
    }
  }

  // Remove favourite from firestore
  Future<void> _removeFavourite(String productId) async {
    try {
      await _firestore.collection("userFavourite").doc(productId).delete();
    } catch (e) {
      print(e);
    }
  }

  // Load favourites from firestore (store favourite or not)
  Future<void> loadFavourites() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection("userFavourite").get();
      _favouriteIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  // Static method to access the provider from any context
  static FavouriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavouriteProvider>(context, listen: listen);
  }
}
