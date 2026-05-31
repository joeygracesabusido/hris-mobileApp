import 'package:dio/dio.dart';
import '../providers/api_client.dart';

class FaceRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<double>> getFaceDescriptor(String employeeId) async {
    final response = await _dio.get('/employees/$employeeId/face-descriptor');
    final data = response.data as Map<String, dynamic>;
    final descriptor = data['faceDescriptor'] as List<dynamic>;
    return descriptor.cast<double>();
  }

  Future<void> enrollFace(String employeeId, List<double> descriptor) async {
    await _dio.put(
      '/employees/$employeeId/face',
      data: {'faceDescriptor': descriptor},
    );
  }
}
