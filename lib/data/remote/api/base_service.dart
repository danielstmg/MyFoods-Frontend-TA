import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

abstract class BaseService {
  static const _timeout = 30000;
  static const _retries = 1;

  late final http.Client _client;

  BaseService() {
    _client = http.Client();
  }

  @protected
  Future<http.Response> get(
      String url, {
        Map<String, String>? headers,
        int? currentTry,
        Map<String, dynamic>? queryParameters,
      }) async {
    int retry = currentTry ?? 0;

    String queryParams = '';
    if (queryParameters != null) {
      queryParams += '?';
      queryParameters.forEach((key, value) {
        queryParams += '$key=$value&';
      });
      queryParams = queryParams.substring(0, queryParams.length - 1);
    }

    try {
      final uri = Uri.parse('$url$queryParams');
      return await _client
          .get(uri, headers: headers)
          .timeout(const Duration(milliseconds: _timeout));
    } on TimeoutException catch (_) {
      if (retry < _retries) {
        retry++;
        return get(url, headers: headers, currentTry: retry);
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }
}