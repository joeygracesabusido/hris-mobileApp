// src/data/providers/employee_repository.dart
import 'package:dio/dio.dart';
import '../../data/models/employee.dart';
import '../providers/api_client.dart';

class EmployeeRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<Employee>> getAll() async {
    final response = await _dio.get('/employees');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((e) => Employee.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Employee> getById(String id) async {
    final response = await _dio.get('/employees/$id');
    return Employee.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Employee> create(Employee employee) async {
    final response = await _dio.post('/employees', data: employee.toJson());
    return Employee.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Employee> update(String id, Employee employee) async {
    final response = await _dio.put('/employees/$id', data: employee.toJson());
    return Employee.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/employees/$id');
  }
}
