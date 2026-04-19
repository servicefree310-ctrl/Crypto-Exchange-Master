import '../constants/api_constants.dart';

/// Utility helper for working with URLs returned from backend APIs.
class UrlUtils {
  /// If [url] is already absolute (has scheme), it is returned unchanged.
  /// If it is a relative path like "/uploads/avatars/x.png" this method
  /// prefixes [ApiConstants.baseUrl] to make it an absolute URL that can be
  /// loaded by network image widgets.
  static String normalise(String? url) {
    if (url == null || url.isEmpty) return '';
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme) return url;
    // Ensure there is exactly one slash between base and path.
    final cleanedBase = ApiConstants.baseUrl.endsWith('/')
        ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
        : ApiConstants.baseUrl;
    final cleanedPath = url.startsWith('/') ? url : '/$url';
    return '$cleanedBase$cleanedPath';
  }
}
