import 'package:dio/dio.dart';
import '../common/dio_client.dart';

class InventoryApiService {
  Future<Response> fetchInventory(int childId) async {
    return await DioClient.dio.get('/api/v1/inventory/$childId');
  }

  Future<Response> equipItem(int inventoryId) async {
    return await DioClient.dio.patch('/api/v1/inventory/$inventoryId/equip');
  }
}