import 'dart:async';
import 'dart:io';

import 'package:condor_cli/src/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// Flutter 管理单例
CondorFlutter flutter = CondorFlutter();

/// Flutter 管理
class CondorFlutter {
  /// 拉取引擎dSYM
  Future<File?> fetchEngineDsymZipFile({
    required String flutterVersion,
  }) async {
    // 检查是否已经下载过
    final dsymPath = flutterDsymZipTempPath(
      flutterVersion: flutterVersion,
    );
    // 如果已经下载过, 直接返回
    if (dsymPath.existsSync()) {
      return dsymPath;
    }
    // 没有下载过, 开始处理
    final engineVersion = await this.engineVersion(
      flutterVersion: flutterVersion,
    );
    if (engineVersion == null) {
      Log.error('无法获取引擎版本');
      return null;
    }
    final url = dsymUrl(engineVersion);
    final uri = Uri.tryParse(url);
    if (uri == null) {
      Log.error('无法解析 Flutter.dSYM 下载地址');
      return null;
    }
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      Log.error('Flutter.dSYM 下载失败: ${response.statusCode}');
      return null;
    }
    await dsymPath.writeAsBytes(response.bodyBytes);
    Log.info('Flutter.dSYM 下载成功: ${dsymPath.path}');
    return dsymPath;
  }

  /// 获取引擎版本
  Future<String?> engineVersion({
    required String flutterVersion,
  }) async {
    final uri = Uri.tryParse(
      'https://raw.githubusercontent.com/flutter/flutter/$flutterVersion/bin/internal/engine.version',
    );
    if (uri == null) {
      Log.error('无法解析 Flutter 引擎版本地址');
      return null;
    }
    final content = await http.get(uri);
    final versionId = content.body.trim();
    Log.info('Flutter $flutterVersion 对应的引擎版本ID: $versionId');
    return versionId;
  }

  /// 根据引擎的版本id, 获取 Flutter.dSYM 的下载地址
  String dsymUrl(String engineVersion) {
    // 原 Google Cloud 下载地址
    // https://console.cloud.google.com/storage/browser/flutter_infra_release/flutter
    // https://storage.cloud.google.com/flutter_infra_release/flutter/0005149dca9b248663adcde4bdd7c6c915a76584/ios-release-nobitcode/Flutter.dSYM.zip
    // return 'https://storage.cloud.google.com/flutter_infra_release/flutter/$engineVersion/ios-release-nobitcode/Flutter.dSYM.zip';
    // 需要登录谷歌账号才能下载，所以这里改用镜像网来下载
    return 'https://mirrors.tuna.tsinghua.edu.cn/flutter/flutter_infra_release/flutter/$engineVersion/ios-release/Flutter.dSYM.zip';
  }

  /// 存放 Flutter 相关资源的临时目录
  Directory flutterTempDir({
    required String flutterVersion,
  }) {
    final condorTempDir = file.getCondorTempDir();
    final flutterDirPath = p.join(
      condorTempDir.path,
      'flutter',
      flutterVersion,
    );
    final flutterDir = Directory(flutterDirPath);
    if (!flutterDir.existsSync()) {
      flutterDir.createSync(recursive: true);
    }
    return flutterDir;
  }

  /// 临时存放 Flutter.dSYM 的位置
  File flutterDsymZipTempPath({
    required String flutterVersion,
  }) {
    final tempDir = flutterTempDir(flutterVersion: flutterVersion);
    final dsymPath = p.join(
      tempDir.path,
      'Flutter.dSYM.zip',
    );
    return File(dsymPath);
  }
}
