import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:nhathuoc_mobilee/models/cartitemlocal.dart';
import 'package:nhathuoc_mobilee/models/giohang.dart';
import 'package:nhathuoc_mobilee/models/thuoc.dart';

class CartManager {
  // Singleton
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  // Local storage: chỉ gồm {maThuoc, soLuong}
  List<CartItemLocal> _localItems = [];

  // ---------------------------------------------------------
  // A. LOCAL STORAGE HANDLING
  // ---------------------------------------------------------

  Future<void> addToCart(int maThuoc, int quantity) async {
    await _loadFromPrefs();

    final index = _localItems.indexWhere((e) => e.maThuoc == maThuoc);

    if (index >= 0) {
      _localItems[index].soLuong += quantity;
    } else {
      _localItems.add(CartItemLocal(maThuoc: maThuoc, soLuong: quantity));
    }

    await _saveToPrefs();
  }

  Future<void> removeFromCart(int maThuoc) async {
    _localItems.removeWhere((item) => item.maThuoc == maThuoc);
    await _saveToPrefs();
  }

  Future<void> updateQuantity(int maThuoc, int newQuantity) async {
    final index = _localItems.indexWhere((e) => e.maThuoc == maThuoc);

    if (index == -1) return;

    if (newQuantity > 0) {
      _localItems[index].soLuong = newQuantity;
    } else {
      _localItems.removeAt(index);
    }

    await _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(_localItems.map((e) => e.toJson()).toList());
    await prefs.setString('my_cart_data', jsonData);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('my_cart_data');

    if (data == null) return;

    final jsonList = jsonDecode(data) as List<dynamic>;
    _localItems = jsonList.map((e) => CartItemLocal.fromJson(e)).toList();
  }

  int get cartCount => _localItems.length;

  // ---------------------------------------------------------
  // B. SYNC TO SERVER FOR DISPLAY
  // ---------------------------------------------------------

  Future<List<GioHang>> fetchCartDetails() async {
    await _loadFromPrefs();
    if (_localItems.isEmpty) return [];

    final listIDs = _localItems.map((e) => e.maThuoc).toList();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.2.9:8476/api/thuoc/get_cart'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ids": listIDs}),
      );

      if (response.statusCode != 200) {
        debugPrint("Server error: ${response.statusCode}");
        return [];
      }

      final jsonRaw = jsonDecode(response.body) as List;
      final listThuoc = jsonRaw.map((e) => Thuoc.fromJson(e)).toList();

      return _mergeLocalAndServer(listThuoc);
    } catch (e) {
      debugPrint("API error: $e");
      return [];
    }
  }

  // Gộp dữ liệu server và local
  List<GioHang> _mergeLocalAndServer(List<Thuoc> listThuoc) {
    return listThuoc.map((thuoc) {
      final local = _localItems.firstWhere(
        (item) => item.maThuoc == thuoc.maThuoc,
        orElse: () => CartItemLocal(maThuoc: -1, soLuong: 1),
      );

      return GioHang(
        maThuoc: thuoc.maThuoc,
        anhURL: thuoc.anhURL,
        donGia: thuoc.donGia,
        tenThuoc: thuoc.tenThuoc,
        soLuong: local.soLuong,
      );
    }).toList();
  }
}
