class Product {
  final String name;
  final double price;
  final String? imagePath;
  final String description;
  final String category;
  bool isFavorite;

  Product({
    required this.name,
    required this.price,
    this.imagePath,
    this.description = 'Dessert lezat SnaTo Bakery.',
    this.category = 'Cake',
    this.isFavorite = false,
  });
}