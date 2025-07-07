import 'package:flutter/material.dart';
import '../models/perfume.dart';

class PerfumeProvider extends ChangeNotifier {
  final List<Perfume> _favorites = [];
  final List<Perfume> _cartItems = [];

  List<Perfume> get favorites => _favorites;
  List<Perfume> get cartItems => _cartItems;

  void toggleFavorite(Perfume perfume) {
    if (isFavorite(perfume)) {
      _favorites.removeWhere((item) => item.id == perfume.id);
    } else {
      _favorites.add(perfume);
    }
    notifyListeners();
  }

  bool isFavorite(Perfume perfume) {
    return _favorites.any((item) => item.id == perfume.id);
  }

  void addToCart(Perfume perfume) {
    _cartItems.add(perfume);
    notifyListeners();
  }

  void removeFromCart(Perfume perfume) {
    _cartItems.removeWhere((item) => item.id == perfume.id);
    notifyListeners();
  }
}
