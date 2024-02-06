import 'dart:async';

import 'package:condor_cli/src/utils/utils.dart';
import 'package:http/http.dart' as http;

/// Flutter 管理单例
CondorFlutter flutter = CondorFlutter();

/// Flutter 管理
class CondorFlutter {
  /// 获取引擎版本
  Future<String?> engineVersion({
    required String flutterVersion,
  }) async {
    final uri = Uri.tryParse(
      'https://github.com/flutter/flutter/blob/$flutterVersion/bin/internal/engine.version',
    );
    if (uri == null) {
      Log.error('无法解析 Flutter 引擎版本地址');
      return null;
    }
    final content = await http.get(uri);
    Log.info('msg: ${content.body}');
    return null;
  }
}
