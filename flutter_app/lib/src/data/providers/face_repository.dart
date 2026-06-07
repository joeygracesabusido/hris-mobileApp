import 'package:dio/dio.dart';
import '../providers/api_client.dart';

class FaceVerificationResult {
  final bool matched;
  final FaceVerificationEmployee? employee;
  final double? distance;

  FaceVerificationResult({
    required this.matched,
    this.employee,
    this.distance,
  });

  factory FaceVerificationResult.fromJson(Map<String, dynamic> json) {
    return FaceVerificationResult(
      matched: json['matched'] as bool? ?? false,
      employee: json['employee'] != null
          ? FaceVerificationEmployee.fromJson(
              json['employee'] as Map<String, dynamic>)
          : null,
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }
}

class FaceVerificationEmployee {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  FaceVerificationEmployee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory FaceVerificationEmployee.fromJson(Map<String, dynamic> json) {
    return FaceVerificationEmployee(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

class FaceEnrollmentStatus {
  final bool enrolled;
  final String employeeName;
  final DateTime? enrolledAt;

  FaceEnrollmentStatus({
    required this.enrolled,
    required this.employeeName,
    this.enrolledAt,
  });

  factory FaceEnrollmentStatus.fromJson(Map<String, dynamic> json) {
    return FaceEnrollmentStatus(
      enrolled: json['enrolled'] as bool? ?? false,
      employeeName: json['employeeName'] as String? ?? '',
      enrolledAt: json['enrolledAt'] != null
          ? DateTime.parse(json['enrolledAt'] as String)
          : null,
    );
  }
}

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

  /// Sends a face descriptor to the backend for server-side verification
  /// against all registered faces in MongoDB.
  ///
  /// Returns [FaceVerificationResult] indicating whether the face matched
  /// any registered employee, along with employee info and match distance.
  Future<FaceVerificationResult> verifyFace(List<double> descriptor) async {
    final response = await _dio.post(
      '/face/verify',
      data: {'faceDescriptor': descriptor},
    );
    return FaceVerificationResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FaceEnrollmentStatus> getEnrollmentStatus() async {
    try {
      final response = await _dio.get('/face/status');
      return FaceEnrollmentStatus.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['error'] as String?;
      if (serverMsg != null) {
        throw Exception('Server: $serverMsg');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timed out. Check your internet connection.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot reach server. Check your internet connection.');
      }
      throw Exception('Failed to check enrollment status (${e.message ?? e.type.toString()})');
    }
  }
}
