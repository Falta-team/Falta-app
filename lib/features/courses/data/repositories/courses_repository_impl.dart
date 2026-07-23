import 'dart:convert';

import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/features/courses/data/models/comment_model.dart';
import 'package:falta_app/features/courses/data/models/course_material_model.dart';
import 'package:falta_app/features/courses/data/models/courses_model.dart';
import 'package:falta_app/features/courses/data/models/video_model.dart';
import 'package:falta_app/features/courses/domain/entities/comment_entity.dart';
import 'package:falta_app/features/courses/domain/entities/course_material_entity.dart';
import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/entities/video_entity.dart';
import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:http/http.dart' as http;

class CoursesApiException implements Exception {
  const CoursesApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CoursesRepositoryImpl implements CoursesRepository {
  const CoursesRepositoryImpl();

  @override
  Future<List<CoursesEntity>> getAllCourses({
    String? search,
    String? subject,
  }) async {
    try {
      final uri = (search != null && search.trim().isNotEmpty) ||
              (subject != null && subject.trim().isNotEmpty)
          ? ApiSettings.coursesQuery(search: search, subject: subject)
          : Uri.parse(ApiSettings.courses);
      final response = await http.get(uri, headers: ApiSettings.jsonHeaders);
      final dynamic body = jsonDecode(response.body);

      if (ApiSettings.isSuccess(response.statusCode)) {
        return _extractList(body)
            .map((e) => CoursesModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw CoursesApiException(
          _extractMessage(body) ?? 'فشل تحميل الكورسات');
    } on CoursesApiException {
      rethrow;
    } catch (e) {
      throw CoursesApiException('خطأ في الاتصال: $e');
    }
  }

  @override
  Future<CoursesEntity> getCourseDetails(String id) async {
    try {
      final uri = Uri.parse(ApiSettings.courseById(id));
      final response = await http.get(uri, headers: ApiSettings.jsonHeaders);
      final dynamic body = jsonDecode(response.body);

      if (ApiSettings.isSuccess(response.statusCode)) {
        return CoursesModel.fromJson(_extractObject(body));
      }
      throw CoursesApiException(
          _extractMessage(body) ?? 'فشل تحميل تفاصيل الكورس');
    } on CoursesApiException {
      rethrow;
    } catch (e) {
      throw CoursesApiException('خطأ في الاتصال: $e');
    }
  }

  @override
  Future<List<CoursesEntity>> getCoursesBySubject(String subject) async {
    try {
      final uri = Uri.parse(ApiSettings.coursesBySubject(subject));
      final response = await http.get(uri, headers: ApiSettings.jsonHeaders);
      final dynamic body = jsonDecode(response.body);
      if (ApiSettings.isSuccess(response.statusCode)) {
        return _extractList(body)
            .map((e) => CoursesModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw CoursesApiException(
          _extractMessage(body) ?? 'فشل تحميل كورسات هذه المادة');
    } on CoursesApiException {
      rethrow;
    } catch (e) {
      throw CoursesApiException('خطأ في الاتصال: $e');
    }
  }

  @override
  Future<List<CoursesEntity>> getCoursesByInstructor(String instructorId) async {
    try {
      final uri = Uri.parse(ApiSettings.coursesByInstructor(instructorId));
      final response = await http.get(uri, headers: ApiSettings.jsonHeaders);
      final dynamic body = jsonDecode(response.body);
      if (ApiSettings.isSuccess(response.statusCode)) {
        return _extractList(body)
            .map((e) => CoursesModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw CoursesApiException(
          _extractMessage(body) ?? 'فشل تحميل كورسات المعلم');
    } on CoursesApiException {
      rethrow;
    } catch (e) {
      throw CoursesApiException('خطأ في الاتصال: $e');
    }
  }

  @override
  Future<void> enrollCourse(String id, String token) async {
    try {
      final uri = Uri.parse(ApiSettings.enrollCourse(id));
      final response =
          await http.post(uri, headers: ApiSettings.authHeaders(token));

      if (ApiSettings.isSuccess(response.statusCode)) return;

      final dynamic body = jsonDecode(response.body);
      throw CoursesApiException(
          _extractMessage(body) ?? 'فشل التسجيل في الكورس');
    } on CoursesApiException {
      rethrow;
    } catch (e) {
      throw CoursesApiException('خطأ في الاتصال: $e');
    }
  }

  @override
  Future<List<VideoEntity>> getCourseVideos(String id, String token) async {
    try {
      final uri = Uri.parse(ApiSettings.courseVideos(id));
      final response =
          await http.get(uri, headers: ApiSettings.authHeaders(token));
      final dynamic body = jsonDecode(response.body);

      if (ApiSettings.isSuccess(response.statusCode)) {
        final videos = _extractVideosList(body)
            .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
            .toList();
        videos.sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));
        return videos;
      }
      throw CoursesApiException(
          _extractMessage(body) ?? 'فشل تحميل فيديوهات الكورس');
    } on CoursesApiException {
      rethrow;
    } catch (e) {
      throw CoursesApiException('خطأ في الاتصال: $e');
    }
  }

  @override
  Future<VideoEntity> getVideoById(String videoId, String token) async {
    try {
      final uri = Uri.parse(ApiSettings.videoById(videoId));
      final response =
          await http.get(uri, headers: ApiSettings.authHeaders(token));
      final dynamic body = jsonDecode(response.body);

      if (ApiSettings.isSuccess(response.statusCode)) {
        final data = body is Map<String, dynamic> ? body['data'] : null;
        final video = data is Map<String, dynamic>
            ? (data['video'] as Map<String, dynamic>? ?? data)
            : <String, dynamic>{};
        return VideoModel.fromJson(video);
      }
      throw CoursesApiException(
          _extractMessage(body) ?? 'فشل تحميل الفيديو');
    } on CoursesApiException {
      rethrow;
    } catch (e) {
      throw CoursesApiException('خطأ في الاتصال: $e');
    }
  }

  @override
  Future<List<CourseMaterialEntity>> getCourseMaterials(
    String courseId,
    String token,
  ) async {
    try {
      final uri = Uri.parse(ApiSettings.courseMaterials(courseId));
      final response =
          await http.get(uri, headers: ApiSettings.authHeaders(token));
      final dynamic body = jsonDecode(response.body);

      if (ApiSettings.isSuccess(response.statusCode)) {
        final materials = _extractMaterialsList(body)
            .map((e) => CourseMaterialModel.fromJson(e as Map<String, dynamic>))
            .toList();
        materials.sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));
        return materials;
      }
      throw CoursesApiException(
          _extractMessage(body) ?? 'فشل تحميل مواد الكورس');
    } on CoursesApiException {
      rethrow;
    } catch (e) {
      throw CoursesApiException('خطأ في الاتصال: $e');
    }
  }

  @override
  Future<List<CommentEntity>> getVideoComments(
      String videoId, String token) async {
    try {
      final uri = Uri.parse(ApiSettings.videoComments(videoId));
      final response =
          await http.get(uri, headers: ApiSettings.authHeaders(token));
      final dynamic body = jsonDecode(response.body);

      if (ApiSettings.isSuccess(response.statusCode)) {
        return _extractCommentsList(body)
            .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw CoursesApiException(
          _extractMessage(body) ?? 'فشل تحميل التعليقات');
    } on CoursesApiException {
      rethrow;
    } catch (e) {
      throw CoursesApiException('خطأ في الاتصال: $e');
    }
  }

  @override
  Future<CommentEntity> addVideoComment(
      String videoId, String token, String body) async {
    try {
      final uri = Uri.parse(ApiSettings.videoComments(videoId));
      final response = await http.post(
        uri,
        headers: ApiSettings.authHeaders(token),
        body: jsonEncode({'body': body}),
      );
      final dynamic decoded = jsonDecode(response.body);

      if (ApiSettings.isSuccess(response.statusCode)) {
        return CommentModel.fromJson(_extractCommentObject(decoded));
      }
      throw CoursesApiException(
          _extractMessage(decoded) ?? 'فشل إرسال التعليق');
    } on CoursesApiException {
      rethrow;
    } catch (e) {
      throw CoursesApiException('خطأ في الاتصال: $e');
    }
  }

  List<dynamic> _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'];
      if (data is Map<String, dynamic>) {
        final dynamic courses = data['courses'];
        if (courses is List) return courses;
      }
      if (data is List) return data;
      final dynamic flat = body['courses'];
      if (flat is List) return flat;
    }
    return const [];
  }

  List<dynamic> _extractVideosList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'];
      if (data is Map<String, dynamic>) {
        final dynamic videos = data['videos'];
        if (videos is List) return videos;
      }
      if (data is List) return data;
      final dynamic flat = body['videos'];
      if (flat is List) return flat;
    }
    return const [];
  }

  List<dynamic> _extractMaterialsList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'];
      if (data is Map<String, dynamic>) {
        final dynamic materials = data['materials'];
        if (materials is List) return materials;
      }
      if (data is List) return data;
      final dynamic flat = body['materials'];
      if (flat is List) return flat;
    }
    return const [];
  }

  List<dynamic> _extractCommentsList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'];
      if (data is Map<String, dynamic>) {
        final dynamic comments = data['comments'];
        if (comments is List) return comments;
      }
      if (data is List) return data;
      final dynamic flat = body['comments'];
      if (flat is List) return flat;
    }
    return const [];
  }

  Map<String, dynamic> _extractCommentObject(dynamic body) {
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'];
      if (data is Map<String, dynamic>) {
        final dynamic comment = data['comment'];
        if (comment is Map<String, dynamic>) return comment;
        return data;
      }
      final dynamic flat = body['comment'];
      if (flat is Map<String, dynamic>) return flat;
      return body;
    }
    return const {};
  }

  Map<String, dynamic> _extractObject(dynamic body) {
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'];
      if (data is Map<String, dynamic>) {
        final dynamic course = data['course'];
        if (course is Map<String, dynamic>) return course;
        return data;
      }
      final dynamic flat = body['course'];
      if (flat is Map<String, dynamic>) return flat;
      return body;
    }
    return const {};
  }

  String? _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      final error = body['error'];
      if (error is Map && error['message'] != null) {
        return error['message'].toString();
      }
      return body['message'] as String?;
    }
    return null;
  }
}
