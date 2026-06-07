import 'package:dio/dio.dart';
import '../models/payroll.dart';
import 'api_client.dart';

class PayrollRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<PayrollRecord>> getPayrolls({String? employeeId, int? month, int? year}) async {
    final response = await _dio.get('/payroll', queryParameters: {
      if (employeeId != null) 'employeeId': employeeId,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
    });
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((e) => PayrollRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PayrollRecord?> computePayroll({
    required String employeeId,
    required String periodStart,
    required String periodEnd,
    required String frequency,
    List<String>? deductions,
    double adjustmentAdd = 0,
    double adjustmentDeduct = 0,
    String adjustmentReason = '',
  }) async {
    final response = await _dio.post('/payroll', data: {
      'employeeId': employeeId,
      'periodStart': periodStart,
      'periodEnd': periodEnd,
      'frequency': frequency,
      'deductions': deductions ?? ['sss', 'philhealth', 'pagibig', 'tax'],
      'adjustmentAdd': adjustmentAdd,
      'adjustmentDeduct': adjustmentDeduct,
      'adjustmentReason': adjustmentReason,
    });
    final payroll = response.data['payroll'];
    return payroll != null ? PayrollRecord.fromJson(payroll as Map<String, dynamic>) : null;
  }
}
