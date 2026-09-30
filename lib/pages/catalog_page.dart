import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/cart_provider.dart';
import '../models/product_model.dart';
import 'cart_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({Key? key}) : super(key: key);

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String selectedCategory = 'Semua';
  String searchQuery = '';
  int activeIndex = 1; // Default ke Katalog

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {'name': 'Semua', 'icon': Icons.cake_outlined},
    {'name': 'Cake', 'icon': Icons.cake_outlined},
    {'name': 'Cupcake', 'icon': Icons.bakery_dining_outlined},
    {'name': 'Roll Cake', 'icon': Icons.donut_large_outlined},
  ];

  final Color primaryDark = const Color(0xFF801B38);
  final Color primaryDeep = const Color(0xFF580C21);
  final Color accentRose  = const Color(0xFFA62B50);
  final Color bgSoft      = const Color(0xFFFFF0F4);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CartProvider>(context, listen: false).fetchProducts();
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  String _formatRupiah(double number) {
    return 'Rp ${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  List<Product> _getFilteredProducts(List<Product> allProducts) {
    return allProducts.where((product) {
      bool matchesCategory = selectedCategory == 'Semua' || product.category == selectedCategory;
      bool matchesSearch = product.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showDeleteDialog(BuildContext context, Product product, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgSoft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Produk? 🗑️',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: primaryDeep),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus "${product.name}" dari katalog?',
          style: GoogleFonts.poppins(fontSize: 13, color: primaryDeep),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: primaryDark, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              cart.deleteProduct(product);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} berhasil dihapus! 🗑️', style: GoogleFonts.poppins(fontSize: 12)),
                  backgroundColor: primaryDeep,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Text('Hapus', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    String newProductCategory = 'Cake';
    XFile? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgSoft,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final mediaQuery = MediaQuery.of(ctx);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Future<void> pickImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
              if (image != null) {
                setModalState(() {
                  selectedImage = image;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: mediaQuery.viewInsets.bottom + 20,
                top: 24,
                left: 20,
                right: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.85),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tambah Produk Baru ✨',
                        style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: primaryDeep),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        style: GoogleFonts.poppins(color: primaryDeep, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: 'Nama Dessert',
                          labelStyle: GoogleFonts.poppins(color: primaryDark, fontWeight: FontWeight.w500),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.poppins(color: primaryDeep, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: 'Harga (Rp)',
                          labelStyle: GoogleFonts.poppins(color: primaryDark, fontWeight: FontWeight.w500),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: newProductCategory,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          labelStyle: GoogleFonts.poppins(color: primaryDark, fontWeight: FontWeight.w500),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        items: ['Cake', 'Cupcake', 'Roll Cake'].map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category, style: GoogleFonts.poppins(color: primaryDeep)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setModalState(() {
                            newProductCategory = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        maxLines: 2,
                        style: GoogleFonts.poppins(color: primaryDeep, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: 'Deskripsi Produk',
                          labelStyle: GoogleFonts.poppins(color: primaryDark, fontWeight: FontWeight.w500),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: pickImage,
                        child: Container(
                          height: 130,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primaryDark, width: 1.8),
                          ),
                          child: selectedImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, size: 38, color: primaryDark),
                                    const SizedBox(height: 8),
                                    Text('Pilih Foto dari Galeri 📸', style: GoogleFonts.poppins(color: primaryDark, fontWeight: FontWeight.w600)),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: kIsWeb
                                      ? Image.network(selectedImage!.path, fit: BoxFit.cover, width: double.infinity)
                                      : Image.file(File(selectedImage!.path), fit: BoxFit.cover, width: double.infinity),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          onPressed: () {
                            final name = nameController.text.trim();
                            final priceText = priceController.text.trim();
                            final price = double.tryParse(priceText) ?? 0.0;
                            final desc = descController.text.trim();

                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Isi nama produk terlebih dahulu! ⚠️', style: GoogleFonts.poppins(color: Colors.white)),
                                  backgroundColor: Colors.red[700],
                                ),
                              );
                              return;
                            }

                            if (price <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Isi harga produk berupa angka valid! ⚠️', style: GoogleFonts.poppins(color: Colors.white)),
                                  backgroundColor: Colors.red[700],
                                ),
                              );
                              return;
                            }

                            Provider.of<CartProvider>(context, listen: false).addProduct(
                              Product(
                                name: name,
                                price: price,
                                imagePath: selectedImage?.path,
                                description: desc.isNotEmpty ? desc : 'Dessert lezat SnaTo Bakery.',
                                category: newProductCategory,
                              ),
                            );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Produk berhasil ditambahkan! 🍰', style: GoogleFonts.poppins(color: Colors.white)),
                                backgroundColor: primaryDark,
                              ),
                            );
                          },
                          child: Text('Simpan Produk', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        color: const Color(0xFFFFEBF2),
        child: Center(child: Icon(Icons.cake_rounded, size: 40, color: primaryDark.withOpacity(0.6))),
      );
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Container(
          color: const Color(0xFFFFEBF2),
          child: Center(child: Icon(Icons.cake_rounded, size: 40, color: primaryDark)),
        ),
      );
    }

    if (kIsWeb || imagePath.startsWith('http://') || imagePath.startsWith('https://') || imagePath.startsWith('blob:')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Container(
          color: const Color(0xFFFFEBF2),
          child: Center(child: Icon(Icons.cake_rounded, size: 40, color: primaryDark)),
        ),
      );
    }

    try {
      final file = File(imagePath);
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Container(
          color: const Color(0xFFFFEBF2),
          child: Center(child: Icon(Icons.cake_rounded, size: 40, color: primaryDark)),
        ),
      );
    } catch (_) {
      return Container(
        color: const Color(0xFFFFEBF2),
        child: Center(child: Icon(Icons.cake_rounded, size: 40, color: primaryDark)),
      );
    }
  }

  Widget _buildProductCard(Product product, int index, CartProvider cart) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryDark.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                    child: _buildProductImage(product.imagePath),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showDeleteDialog(context, product, cart),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red[700]),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          cart.toggleFavorite(product);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                product.isFavorite ? '${product.name} ditambahkan ke favorit! ❤️' : '${product.name} dihapus dari favorit',
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: primaryDeep,
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            product.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 16,
                            color: product.isFavorite ? primaryDark : primaryDark.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 14, color: primaryDeep),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatRupiah(product.price),
                          style: GoogleFonts.poppins(color: accentRose, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: GoogleFonts.poppins(fontSize: 10, color: primaryDeep.withOpacity(0.7)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        cart.addToCart(product);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} masuk keranjang! 🛒', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                            duration: const Duration(seconds: 1),
                            backgroundColor: primaryDeep,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('+ Keranjang', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeView(CartProvider cart) {
    final filtered = _getFilteredProducts(cart.products);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryDark, primaryDeep]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Freshly Baked Everyday! 🥐', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Text('Nikmati Diskon 20% Hari Ini', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Dessert Pilihan 🍰', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDeep)),
          const SizedBox(height: 12),
          filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Text('Tidak ada produk yang cocok 🍰', style: GoogleFonts.poppins(color: primaryDark)),
                  ),
                )
              : LayoutBuilder(
                  builder: (ctx, constraints) {
                    double screenWidth = constraints.maxWidth;
                    int crossAxisCount = screenWidth > 900 ? 3 : 2;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.64,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemBuilder: (context, i) => _buildProductCard(filtered[i], i, cart),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildCatalogView(CartProvider cart) {
    final filtered = _getFilteredProducts(cart.products);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: categories.map((cat) {
              bool isSelected = selectedCategory == cat['name'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = cat['name'];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? primaryDark : primaryDark.withOpacity(0.3), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Icon(cat['icon'], size: 15, color: isSelected ? Colors.white : primaryDark),
                        const SizedBox(width: 6),
                        Text(cat['name'], style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : primaryDark)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text('Belum ada produk di kategori $selectedCategory 🍰', style: GoogleFonts.poppins(color: primaryDark)),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    int crossAxisCount = screenWidth > 900 ? 3 : 2;
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      itemCount: filtered.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.64,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemBuilder: (ctx, i) => _buildProductCard(filtered[i], i, cart),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFavoriteView(CartProvider cart) {
    final favoriteProducts = _getFilteredProducts(cart.products.where((p) => p.isFavorite).toList());

    if (favoriteProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 60, color: primaryDark.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text('Belum Ada Favorit 💔', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDeep)),
            const SizedBox(height: 6),
            Text('Tekan ikon hati pada produk untuk menyimpannya di sini', style: GoogleFonts.poppins(fontSize: 12, color: primaryDark.withOpacity(0.6))),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        int crossAxisCount = screenWidth > 900 ? 3 : 2;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          itemCount: favoriteProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.64,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (ctx, i) => _buildProductCard(favoriteProducts[i], i, cart),
        );
      },
    );
  }

  Widget _buildProfileView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: primaryDark,
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text("SnaTo' Bakery Member", style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: primaryDeep)),
          Text("snato.bakery@gmail.com", style: GoogleFonts.poppins(fontSize: 12, color: primaryDark.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = activeIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          activeIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? primaryDark : primaryDark.withOpacity(0.4),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? primaryDark : primaryDark.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    Widget currentBody;
    switch (activeIndex) {
      case 0:
        currentBody = _buildHomeView(cart);
        break;
      case 1:
        currentBody = _buildCatalogView(cart);
        break;
      case 2:
        currentBody = _buildFavoriteView(cart);
        break;
      case 3:
        currentBody = _buildProfileView();
        break;
      default:
        currentBody = _buildHomeView(cart);
    }

    return Scaffold(
      backgroundColor: bgSoft,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "SnaTo' Bakery",
                            style: GoogleFonts.allura(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: primaryDark,
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(height: 1.5, width: 12, color: primaryDark),
                              const SizedBox(width: 4),
                              Text(
                                'Sweet Desserts & Pastry',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: primaryDeep,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('🤍', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 4),
                              Container(height: 1.5, width: 12, color: primaryDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartPage()),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: primaryDark.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.shopping_bag_outlined, color: primaryDark, size: 22),
                        ),
                        if (cart.totalItems > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: primaryDark, shape: BoxShape.circle),
                              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                              child: Text(
                                '${cart.totalItems}',
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar Interaktif
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: primaryDark.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: primaryDark, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        style: GoogleFonts.poppins(fontSize: 12, color: primaryDeep),
                        decoration: InputDecoration(
                          hintText: 'Cari dessert favoritmu...',
                          hintStyle: GoogleFonts.poppins(color: primaryDeep.withOpacity(0.5), fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            searchController.clear();
                            searchQuery = '';
                          });
                        },
                        child: Icon(Icons.close_rounded, color: primaryDark, size: 18),
                      ),
                  ],
                ),
              ),
            ),

            // Main Body
            Expanded(child: currentBody),
          ],
        ),
      ),

      // FAB Tambah Produk
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 10),
        child: FloatingActionButton.extended(
          backgroundColor: primaryDark,
          elevation: 5,
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: Text(
            'Tambah Produk',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
          ),
          onPressed: () => _showAddProductDialog(context),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: primaryDark.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 'Beranda', 0),
            _buildNavItem(Icons.grid_view_rounded, 'Katalog', 1),
            _buildNavItem(Icons.favorite_outline_rounded, 'Favorit', 2),
            _buildNavItem(Icons.person_outline_rounded, 'Profil', 3),
          ],
        ),
      ),
    );
  }
}