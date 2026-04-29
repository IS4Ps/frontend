import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/store/item_model.dart';
import '../../repository/store/store_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StoreViewModel extends ChangeNotifier {
  final StoreRepository _repository = StoreRepository();

  bool _isLoading = false;
  List<ItemModel> _items = [];

  bool get isLoading => _isLoading;
  List<ItemModel> get items => _items;

  final String _testToken = dotenv.env['TEST_TOKEN'] ?? "";

  int _getChildIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 1;

      String payload = parts[1];
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      final String decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> json = jsonDecode(decoded);

      return int.parse(json['sub'].toString());
    } catch (e) {
      print("토큰 디코딩 에러: $e");
      return 1;
    }
  }

  Future<void> loadStoreItems(int childLevel, int childJobId) async {
    _isLoading = true;
    notifyListeners();

    _items = await _repository.getStoreItems(childLevel, childJobId, _testToken) ?? [];

    _isLoading = false;
    notifyListeners();
  }
}