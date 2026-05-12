import 'package:dio/dio.dart';
import '../common/dio_client.dart';

class StoreApiService {
  // 상점 아이템 조회
  Future<Response> fetchStoreItems(int childLevel, int childJobId) async {
    return await DioClient.dio.get(
      '/api/v1/items',
      queryParameters: {'childLevel': childLevel, 'childJobId': childJobId},
    );
  }

  // 아이템 구매
  Future<Response> purchaseItem(int itemId, int childId) async {
    return await DioClient.dio.post(
      '/api/v1/inventory/$itemId/purchase',
      queryParameters: {'childId': childId},
    );
  }
}