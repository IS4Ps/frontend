import 'package:dio/dio.dart';
import '../common/dio_client.dart';

class PresetApiService {
  Future<Response> savePresetFromDate(Map<String, dynamic> body) async {
    return await DioClient.dio.post('/api/v1/presets/save-from-date', data: body);
  }

  Future<Response> getPresets(int parentId) async {
    return await DioClient.dio.get('/api/v1/presets', queryParameters: {'parentId': parentId});
  }

  Future<Response> updatePreset(int presetId, Map<String, dynamic> body) async {
    return await DioClient.dio.put('/api/v1/presets/$presetId', data: body);
  }

  Future<Response> deletePreset(int presetId) async {
    return await DioClient.dio.delete('/api/v1/presets/$presetId');
  }

  Future<Response> loadPreset(int presetId, Map<String, dynamic> body) async {
    return await DioClient.dio.post('/api/v1/presets/$presetId/load', data: body);
  }
}