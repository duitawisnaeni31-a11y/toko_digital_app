import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() => {
        'product': {
          'name': product.name,
          'price': product.price,
          'imagePath': product.imagePath,
          'description': product.description,
          'category': product.category,
          'isFavorite': product.isFavorite,
        },
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final p = json['product'];
    return CartItem(
      product: Product(
        name: p['name'],
        price: (p['price'] as num).toDouble(),
        imagePath: p['imagePath'],
        description: p['description'],
        category: p['category'],
        isFavorite: p['isFavorite'] ?? false,
      ),
      quantity: json['quantity'],
    );
  }
}

class CartProvider with ChangeNotifier {
  List<Product> _products = [];
  List<CartItem> _cartItems = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  CartProvider() {
    _loadDataFromStorage();
  }

  // --- PENYIMPANAN DATA LOKAL (PERSISTENCE) ---
  Future<void> _saveDataToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Simpan Daftar Produk
    final productsJsonList = _products.map((p) => {
      'name': p.name,
      'price': p.price,
      'imagePath': p.imagePath,
      'description': p.description,
      'category': p.category,
      'isFavorite': p.isFavorite,
    }).toList();
    await prefs.setString('saved_products', jsonEncode(productsJsonList));

    // Simpan Isi Keranjang
    final cartJsonList = _cartItems.map((item) => item.toJson()).toList();
    await prefs.setString('saved_cart', jsonEncode(cartJsonList));
  }

  Future<void> _loadDataFromStorage() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    // Memuat Produk
    final savedProductsString = prefs.getString('saved_products');
    if (savedProductsString != null && savedProductsString.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(savedProductsString);
      _products = decoded.map((p) => Product(
        name: p['name'],
        price: (p['price'] as num).toDouble(),
        imagePath: p['imagePath'],
        description: p['description'],
        category: p['category'],
        isFavorite: p['isFavorite'] ?? false,
      )).toList();
    } else {
      // Default Data bawaan pertama kali
      _products = [
        Product(
          name: 'Strawberry Shortcake',
          price: 35000,
          imagePath: 'assets/strawberry shortcake.jpg',
          description: 'Kue spons lembut dengan lapisan krim vanila dan potongan stroberi segar.',
          category: 'Cake',
        ),
        Product(
          name: 'Blueberry Macaron',
          price: 45000,
          imagePath: 'assets/bluberry macaron box.jpg',
          description: 'Macaron renyah dengan isian selai blueberry asli manis asam gurih.',
          category: 'Cake',
        ),
        Product(
          name: 'Pink Velvet Cupcake',
          price: 25000,
          imagePath: 'assets/pink velvet cupcake.jpg',
          description: 'Cupcake velvet merah muda dengan topping cream cheese lumer.',
          category: 'Cupcake',
        ),
      ];
      await _saveDataToStorage();
    }

    // Memuat Keranjang
    final savedCartString = prefs.getString('saved_cart');
    if (savedCartString != null && savedCartString.isNotEmpty) {
      final List<dynamic> decodedCart = jsonDecode(savedCartString);
      _cartItems = decodedCart.map((item) => CartItem.fromJson(item)).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- KALKULASI TOTAL ---
  int get totalItems {
    int total = 0;
    for (var item in _cartItems) {
      total += item.quantity;
    }
    return total;
  }

  double get totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  // --- LOGIKA AKSI ---
  void fetchProducts() {
    _loadDataFromStorage();
  }

  void fetchCart() {
    _loadDataFromStorage();
  }

  void addProduct(Product newProduct) {
    _products.add(newProduct);
    _saveDataToStorage();
    notifyListeners();
  }

  void deleteProduct(Product product) {
    _products.removeWhere((p) => p.name == product.name);
    _cartItems.removeWhere((item) => item.product.name == product.name);
    _saveDataToStorage();
    notifyListeners();
  }

  void addToCart(Product product) {
    int index = _cartItems.indexWhere((item) => item.product.name == product.name);
    if (index >= 0) {
      _cartItems[index].quantity++;
    } else {
      _cartItems.add(CartItem(product: product, quantity: 1));
    }
    _saveDataToStorage();
    notifyListeners();
  }

  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _cartItems.remove(item);
    }
    _saveDataToStorage();
    notifyListeners();
  }

  void increaseQuantity(CartItem item) {
    item.quantity++;
    _saveDataToStorage();
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _cartItems.remove(item);
    _saveDataToStorage();
    notifyListeners();
  }

  // Keranjang HANYA akan dibersihkan saat fungsi Checkout ini dipanggil
  void clearCart() {
    _cartItems.clear();
    _saveDataToStorage();
    notifyListeners();
  }

  void toggleFavorite(Product product) {
    product.isFavorite = !product.isFavorite;
    _saveDataToStorage();
    notifyListeners();
  }
}