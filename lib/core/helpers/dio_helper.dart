import 'package:dio/dio.dart';
import 'package:team_manager/core/constants/app_constants.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/core/helpers/secure_storage_helper.dart';
import 'package:team_manager/core/utils/app_router.dart';

/// Central Dio HTTP client.
///
/// Reads the JWT token from [SecureStorageHelper] (encrypted) and attaches
/// it to every request as a `Bearer` token. Uses [QueuedInterceptorsWrapper]
/// so that the async token read doesn't race with concurrent requests.
class DioHelper {
  static late Dio dio;

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {"Content-Type": "application/json"},
        receiveDataWhenStatusError: true,
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Read token from encrypted storage
          final token = await SecureStorageHelper.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        onError: (DioException error, handler) async {
          final statusCode = error.response?.statusCode;

          // Token expired / unauthorized
          if (statusCode == 401) {
            await SecureStorageHelper.deleteToken();
            await CacheHelper.removeData(key: 'role');
            await CacheHelper.setBool(key: 'auth_active', value: false);

            // Trigger redirect to login
            AppRouter.authNotifier.notify();
          }

          return handler.next(error);
        },
      ),
    );
  }

  static Future<Response> getData({required String url}) async {
    return await dio.get(url);
  }

  static Future<Response> postData({
    required String url,
    required Map<String, dynamic> data,
  }) async {
    return await dio.post(url, data: data);
  }

  static Future<Response> putData({
    required String url,
    required Map<String, dynamic> data,
  }) async {
    return await dio.put(url, data: data);
  }

  static Future<Response> patchData({required String url, dynamic data}) async {
    return await dio.patch(url, data: data);
  }

  static Future<Response> deleteData({required String url, dynamic data}) async {
    return await dio.delete(url, data: data);
  }

  /// Upload files as multipart/form-data.
  ///
  /// ```dart
  /// await DioHelper.uploadFiles(
  ///   url: '/api/v1/task/$id',
  ///   files: [File('path/to/file.jpg')],
  ///   fieldName: 'files',
  /// );
  /// ```
  static Future<Response> uploadFiles({
    required String url,
    required List<String> filePaths,
    String fieldName = 'files',
    Map<String, dynamic>? extraFields,
  }) async {
    final map = <String, dynamic>{};

    if (extraFields != null) {
      map.addAll(extraFields);
    }

    map[fieldName] = await Future.wait(
      filePaths.map(
        (path) => MultipartFile.fromFile(path, filename: path.split('/').last),
      ),
    );

    final formData = FormData.fromMap(map);
    return await dio.patch(url, data: formData);
  }
}
