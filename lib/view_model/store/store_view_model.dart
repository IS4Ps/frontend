import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/auth/token_manager.dart' as my_auth;
import 'package:frontend/models/store/item_model.dart';
import '../../repository/store/store_repository.dart';

class StoreViewModel extends ChangeNotifier {
  final StoreRepository _repository = StoreRepository();

  bool _isLoading = false;
  List<ItemModel> _items = [];

  bool get isLoading => _isLoading;
  List<ItemModel> get items => _items;

  Future<int> _getChildId() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('selectedChildId');
    if (savedId != null) return int.parse(savedId);
    throw Exception("자녀 ID가 없습니다.");
  }

  String _getAccessToken() {
    return my_auth.TokenManager().token ?? "";
  }

  Future<int> getChildId() async {
    return await _getChildId();
  }

  Future<void> loadStoreItems(int childLevel, int childJobId) async {
    _isLoading = true;
    notifyListeners();

    final String token = _getAccessToken();
    _items = await _repository.getStoreItems(childLevel, childJobId, token) ?? [];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> purchaseItem(int itemId, int childId, int childLevel, int childJobId) async {
    _isLoading = true;
    notifyListeners();

    final String token = _getAccessToken();
    final bool isSuccess = await _repository.purchaseItem(itemId, childId, token);

    if (isSuccess) {
      print("[구매 성공] 아이템 구매 완료");
      await loadStoreItems(childLevel, childJobId);
    } else {
      print("[구매 실패] 아이템 구매 실패");
    }

    _isLoading = false;
    notifyListeners();
  }
}