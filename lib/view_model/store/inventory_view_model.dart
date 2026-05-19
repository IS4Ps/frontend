import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/auth/token_manager.dart' as my_auth;
import 'package:frontend/models/store/inventory_model.dart';
import '../../repository/store/inventory_repository.dart';

class InventoryViewModel extends ChangeNotifier {
  final InventoryRepository _repository = InventoryRepository();

  bool _isLoading = false;
  List<InventoryModel> _items = [];

  bool get isLoading => _isLoading;
  List<InventoryModel> get items => _items;

  Future<int> _getChildId() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('selectedChildId');
    if (savedId != null) return int.parse(savedId);
    throw Exception("자녀 ID가 없습니다.");
  }

  String _getAccessToken() {
    return my_auth.TokenManager().token ?? "";
  }

  Future<void> loadInventory() async {
    _isLoading = true;
    notifyListeners();

    final int childId = await _getChildId();
    final String token = _getAccessToken();
    _items = await _repository.getInventory(childId, token) ?? [];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> equipItem(int inventoryId) async {
    _isLoading = true;
    notifyListeners();

    final String token = _getAccessToken();
    final bool isSuccess = await _repository.equipItem(inventoryId, token);

    if (isSuccess) {
      print("[장착/해제 성공]");
      await loadInventory();
    } else {
      print("[장착/해제 실패]");
    }

    _isLoading = false;
    notifyListeners();
  }
}