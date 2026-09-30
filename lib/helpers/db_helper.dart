import 'dart:io';
import 'package:flutter/material.dart';

class AppHelper {
  // 1. Helper untuk Format Angka ke Rupiah
  static String formatRupiah(double number) {
    return 'Rp ${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // 2. Helper Pemanggil Gambar (Support Galeri Android, Network URL, & Asset)
  static Widget buildProductImage(String? imagePath, {Color iconColor = const Color(0xFF801B38)}) {
    if (imagePath == null || imagePath.isEmpty) {
      return Center(
        child: Icon(
          Icons.cake_rounded,
          size: 45,
          color: iconColor.withOpacity(0.6),
        ),
      );
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Center(
          child: Icon(Icons.cake_rounded, size: 45, color: iconColor),
        ),
      );
    }

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Center(
          child: Icon(Icons.cake_rounded, size: 45, color: iconColor),
        ),
      );
    }

    // Membaca File Gambar dari Galeri HP Android
    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (ctx, err, stack) => Center(
        child: Icon(Icons.cake_rounded, size: 45, color: iconColor),
      ),
    );
  }
}