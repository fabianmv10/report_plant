import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

/// Cliente HTTP centralizado usando Dio
class DioClient {
  late final Dio _dio;
  final AppConfig _config;

  DioClient(this._config) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _config.apiBaseUrl,
        connectTimeout: Duration(seconds: _config.apiTimeoutSeconds),
        receiveTimeout: Duration(seconds: _config.apiTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Agregar interceptores para logging y manejo de errores
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
  }

  Dio get instance => _dio;

  /// Actualizar token de autenticación
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remover token de autenticación
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

/// Interceptor para logging de requests/responses
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.debug(
      '🌐 REQUEST[${options.method}] => ${options.uri}\n'
      'Headers: ${options.headers}\n'
      'Data: ${options.data}',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.debug(
      '✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}\n'
      'Data: ${response.data}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.error(
      '❌ ERROR[${err.response?.statusCode}] => ${err.requestOptions.uri}\n'
      'Message: ${err.message}\n'
      'Data: ${err.response?.data}',
      err,
      err.stackTrace,
    );
    super.onError(err, handler);
  }
}

/// Interceptor para manejo centralizado de errores
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Aquí podrías agregar lógica para refresh tokens, retry, etc.
    super.onError(err, handler);
  }
}
