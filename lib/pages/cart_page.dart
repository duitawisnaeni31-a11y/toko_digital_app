import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  final Color primaryDark = const Color(0xFF801B38);
  final Color primaryDeep = const Color(0xFF580C21);
  final Color bgSoft      = const Color(0xFFFFF0F4);

  String _formatRupiah(double number) {
    return 'Rp ${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Helper widget untuk menampilkan gambar produk di keranjang
  Widget _buildProductImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBF2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.cake_rounded, size: 30, color: primaryDark),
      );
    }

    if (imagePath.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBF2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.cake_rounded, size: 30, color: primaryDark),
          ),
        ),
      );
    }

    if (kIsWeb || imagePath.startsWith('http://') || imagePath.startsWith('https://') || imagePath.startsWith('blob:')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imagePath,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBF2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.cake_rounded, size: 30, color: primaryDark),
          ),
        ),
      );
    }

    try {
      final file = File(imagePath);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          file,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBF2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.cake_rounded, size: 30, color: primaryDark),
          ),
        ),
      );
    } catch (_) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBF2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.cake_rounded, size: 30, color: primaryDark),
      );
    }
  }

  void _showCheckoutDialog(BuildContext context, CartProvider cart) {
    final totalAmount = cart.totalPrice;
    final totalItemCount = cart.totalItems;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgSoft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(
          child: Text(
            'Checkout Berhasil! 🎉',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: primaryDeep, fontSize: 20),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: primaryDark, size: 60),
            const SizedBox(height: 12),
            Text(
              'Terima kasih telah berbelanja di SnaTo\' Bakery!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: primaryDeep),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryDark.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jumlah Makanan:', style: GoogleFonts.poppins(fontSize: 12, color: primaryDeep)),
                      Text('$totalItemCount item', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: primaryDeep)),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Pembelian:', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: primaryDeep)),
                      Text(_formatRupiah(totalAmount), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: primaryDark)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                cart.clearCart(); // Menghapus keranjang setelah checkout selesai
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text('Kembali ke Katalog', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        backgroundColor: primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Keranjang Belanja 🛒',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: cart.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 70, color: primaryDark.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('Keranjang Masih Kosong 🛒', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDeep)),
                  const SizedBox(height: 6),
                  Text('Yuk pilih dessert favoritmu di katalog!', style: GoogleFonts.poppins(fontSize: 12, color: primaryDark.withValues(alpha: 0.7))),
                ],
              ),
            )
          : Column(
              children: [
                // Info Jumlah Jenis/Banyak Makanan yang Dibeli
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: primaryDark.withValues(alpha: 0.08),
                  child: Row(
                    children: [
                      Icon(Icons.fastfood_outlined, size: 18, color: primaryDark),
                      const SizedBox(width: 8),
                      Text(
                        'Total Makanan Dibeli: ${cart.totalItems} item (${cart.cartItems.length} jenis)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryDeep,
                        ),
                      ),
                    ],
                  ),
                ),

                // Daftar Produk di Keranjang
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.cartItems.length,
                    itemBuilder: (ctx, i) {
                      final item = cart.cartItems[i];
                      final itemTotalPrice = item.product.price * item.quantity;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: primaryDark.withValues(alpha: 0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: primaryDark.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // 📸 Foto Makanan
                            _buildProductImage(item.product.imagePath),
                            const SizedBox(width: 12),

                            // Info Nama & Harga Produk
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: GoogleFonts.playfairDisplay(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: primaryDeep,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatRupiah(item.product.price),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: primaryDark.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Subtotal: ${_formatRupiah(itemTotalPrice)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Control Tombol - / + dan Kuantitas
                            Container(
                              decoration: BoxDecoration(
                                color: bgSoft,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: primaryDark.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(Icons.remove, size: 16, color: primaryDark),
                                    onPressed: () => cart.decreaseQuantity(item),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      '${item.quantity}x',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: primaryDeep,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(Icons.add, size: 16, color: primaryDark),
                                    onPressed: () => cart.increaseQuantity(item),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bagian Bawah: Total Seluruh Pembelian & Tombol Checkout
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: primaryDark.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jumlah Makanan:',
                            style: GoogleFonts.poppins(fontSize: 13, color: primaryDeep),
                          ),
                          Text(
                            '${cart.totalItems} Makanan',
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: primaryDeep),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Seluruh Pembelian:',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryDeep,
                            ),
                          ),
                          Text(
                            _formatRupiah(cart.totalPrice),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 3,
                          ),
                          onPressed: () => _showCheckoutDialog(context, cart),
                          child: Text(
                            'Checkout Sekarang 💳',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}