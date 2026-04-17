import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

/**
 * HTTP服务类 - 使用Dio封装网络请求
 */
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  late final Dio _dio;

  HttpService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseURL,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  Future<Response> get(String url, {Map<String, dynamic>? params}) async {
    return await _dio.get(url, queryParameters: params);
  }

  Future<Response> post(String url, {dynamic data}) async {
    return await _dio.post(url, data: data);
  }

  Future<void> saveToken(String token) async {
    // SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usertoken', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usertoken');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usertoken');
  }
}