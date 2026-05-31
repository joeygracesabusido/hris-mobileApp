import 'package:dio/dio.dart';
import '../../data/models/time_log.dart';
import '../providers/api_client.dart';

class TimeLogRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<TimeLog>> getAll() async {
    final response = await _dio.get('/time-logs');
    final dynamic rawData = response.data;
    
    List<dynamic> data = [];
    if (rawData is List) {
      data = rawData;
    } else if (rawData is Map) {
      // Check common keys for list data
      if (rawData['data'] is List) {
        data = rawData['data'];
      } else if (rawData['timeLogs'] is List) {
        data = rawData['timeLogs'];
      } else if (rawData['results'] is List) {
        data = rawData['results'];
      } else if (rawData['logs'] is List) {
        data = rawData['logs'];
      }
    }

    return data
        .map((e) => TimeLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TimeLog>> getByEmployeeId(String employeeId) async {
    final response =
        await _dio.get('/time-logs', queryParameters: {'employeeId': employeeId});
    final dynamic rawData = response.data;

    List<dynamic> data = [];
    if (rawData is List) {
      data = rawData;
    } else if (rawData is Map) {
      if (rawData['data'] is List) {
        data = rawData['data'];
      } else if (rawData['timeLogs'] is List) {
        data = rawData['timeLogs'];
      } else if (rawData['results'] is List) {
        data = rawData['results'];
      } else if (rawData['logs'] is List) {
        data = rawData['logs'];
      }
    }

    return data
        .map((e) => TimeLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> clockIn(String employeeId, {double? latitude, double? longitude}) async {
    final data = <String, dynamic>{
      'employeeId': employeeId,
      'type': 'clockIn',
    };
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    await _dio.post('/time-logs', data: data);
  }

  Future<void> clockOut(String employeeId, {double? latitude, double? longitude}) async {
    final data = <String, dynamic>{
      'employeeId': employeeId,
      'type': 'clockOut',
    };
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    await _dio.post('/time-logs', data: data);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/time-logs', queryParameters: {'id': id});
  }
}
