import 'package:flutter/material.dart';

class Quentityprovider extends ChangeNotifier {
  int _currentNumber = 1;
  List<double> _baseIngredientAmounts = [];
  int get currentNumber => _currentNumber;
  // Initial Ingredients
  void setBaseIngredientAmounts(List<double> amounts) {
    _baseIngredientAmounts = amounts;
    notifyListeners();
  }

  // Update Ingredient amounts
  List<String> get updateIngredientAmounts {
    return _baseIngredientAmounts
        .map<String>((amount) => (amount * _currentNumber).toStringAsFixed(1))
        .toList();
  }

  // Increase Servings
  void increaseQuentity() {
    _currentNumber++;
    notifyListeners();
  }

  // Decrement Servings
  void decreaseQuentity() {
    if (_currentNumber > 1) {
      _currentNumber--;
    }

    notifyListeners();
  }
}
