import 'dart:convert';
import 'dart:io';

class UpdateInfo {
  final String latestVersion;
  final String releaseUrl;

  const UpdateInfo({
    required this.latestVersion,
    required this.releaseUrl,
  });
}

class UpdateCheckService {
  static const String _owner = 'Gruenbaer';
  static const String _repo = 'FoulAndFortune';
  static const String latestReleaseUrl =
      'https://github.com/$_owner/$_repo/releases/latest';

  Future<UpdateInfo?> checkForUpdate(String currentVersion) async {
    final latest = await _fetchLatestVersion();
    if (latest == null) return null;

    if (_isNewerVersion(latest, currentVersion)) {
      return UpdateInfo(
        latestVersion: latest,
        releaseUrl: latestReleaseUrl,
      );
    }

    return null;
  }

  Future<String?> _fetchLatestVersion() async {
    final client = HttpClient();
    try {
      final uri = Uri.https(
        'api.github.com',
        '/repos/$_owner/$_repo/releases/latest',
      );

      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      request.headers.set(HttpHeaders.userAgentHeader, 'FoulAndFortune-App');

      final response = await request.close();
      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;

      final tag = decoded['tag_name'] as String?;
      if (tag == null || tag.isEmpty) return null;

      return _normalizeVersion(tag);
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  String _normalizeVersion(String version) {
    final trimmed = version.trim();
    if (trimmed.startsWith('v') || trimmed.startsWith('V')) {
      return trimmed.substring(1);
    }
    return trimmed;
  }

  bool _isNewerVersion(String latest, String current) {
    final latestParts = _toIntParts(_normalizeVersion(latest));
    final currentParts = _toIntParts(_normalizeVersion(current));
    final maxLen = latestParts.length > currentParts.length
        ? latestParts.length
        : currentParts.length;

    for (int i = 0; i < maxLen; i++) {
      final l = i < latestParts.length ? latestParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  List<int> _toIntParts(String version) {
    return version
        .split('.')
        .map((part) {
          final numeric = part.replaceAll(RegExp(r'[^0-9]'), '');
          return int.tryParse(numeric) ?? 0;
        })
        .toList(growable: false);
  }
}
