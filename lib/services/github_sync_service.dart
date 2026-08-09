import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱의 단어 설정(난이도·개수)을 GitHub 저장소의 daily_config.json 에 반영한다.
/// 카카오톡 발송은 GitHub 서버에서 돌기 때문에, 폰 설정을 저장소로 올려줘야
/// 카톡 발송에도 똑같이 적용된다.
class GithubSyncService {
  GithubSyncService._();
  static final GithubSyncService instance = GithubSyncService._();

  static const String owner = 'hyungzn-ai';
  static const String repo = 'hyungzn';
  static const String path = 'data/daily_config.json';

  static const _kToken = 'github_token';
  static const _kLastSync = 'github_last_sync';

  String _token = '';
  String _lastSync = '';

  String get token => _token;
  bool get hasToken => _token.isNotEmpty;
  String get lastSync => _lastSync;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kToken) ?? '';
    _lastSync = prefs.getString(_kLastSync) ?? '';
  }

  Future<void> saveToken(String token) async {
    _token = token.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, _token);
  }

  Future<void> clearToken() async {
    _token = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
  }

  Uri get _uri => Uri.https(
        'api.github.com',
        '/repos/' + owner + '/' + repo + '/contents/' + path,
      );

  Future<Map<String, dynamic>?> _request(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
  }) async {
    final client = HttpClient();
    try {
      client.connectionTimeout = const Duration(seconds: 15);
      final req = await client.openUrl(method, uri);
      req.headers.set('Authorization', 'Bearer ' + _token);
      req.headers.set('Accept', 'application/vnd.github+json');
      req.headers.set('User-Agent', 'writemon-app');
      if (body != null) {
        req.headers.contentType = ContentType.json;
        req.add(utf8.encode(jsonEncode(body)));
      }
      final res = await req.close();
      final text = await res.transform(utf8.decoder).join();
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(text);
        return decoded is Map<String, dynamic> ? decoded : {'ok': true};
      }
      return {'_error': 'HTTP ' + res.statusCode.toString(), '_body': text};
    } catch (e) {
      return {'_error': e.toString()};
    } finally {
      client.close(force: true);
    }
  }

  /// 성공하면 null, 실패하면 사용자에게 보여줄 오류 메시지를 반환
  Future<String?> pushConfig({
    required Set<String> levels,
    required int perDay,
  }) async {
    if (!hasToken) return 'GitHub 토큰이 없어요. 먼저 토큰을 저장해주세요.';

    // 1) 현재 파일의 sha 조회
    final current = await _request('GET', _uri);
    if (current == null) return '저장소에 연결하지 못했어요.';
    if (current['_error'] != null) {
      final err = current['_error'].toString();
      if (err.contains('401')) return '토큰이 올바르지 않아요. 다시 확인해주세요.';
      if (err.contains('403')) return '토큰 권한이 부족해요. Contents 쓰기 권한이 필요해요.';
      if (err.contains('404')) return '설정 파일을 찾지 못했어요.';
      return '조회 실패: ' + err;
    }
    final sha = current['sha'] as String?;

    // 2) 새 설정 작성
    final ordered = ['B1', 'B2', 'C1'].where(levels.contains).toList();
    final config = {
      '_설명': '앱에서 자동으로 갱신됩니다. 직접 고쳐도 됩니다.',
      'levels': ordered.isEmpty ? ['B1', 'B2', 'C1'] : ordered,
      'perDay': perDay,
    };
    final content =
        base64Encode(utf8.encode(const JsonEncoder.withIndent('  ').convert(config)));

    final res = await _request('PUT', _uri, body: {
      'message': 'chore: 앱에서 카톡 발송 설정 변경',
      'content': content,
      if (sha != null) 'sha': sha,
    });
    if (res == null) return '저장소에 연결하지 못했어요.';
    if (res['_error'] != null) return '저장 실패: ' + res['_error'].toString();

    _lastSync = DateTime.now().toString().substring(0, 16);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastSync, _lastSync);
    return null;
  }
}
