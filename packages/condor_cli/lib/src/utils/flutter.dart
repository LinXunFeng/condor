import 'dart:async';
import 'dart:io';

import 'package:condor_cli/src/common.dart';
import 'package:condor_cli/src/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// Flutter 管理单例
CondorFlutter flutter = CondorFlutter();

/// Flutter 管理
class CondorFlutter {
  /// 获取 Flutter 版本
  Future<String?> version(
    String? flutterCmd,
  ) {
    String? flutterProcess;
    var arguments = <String>[];
    final cmd = (flutterCmd ?? '').trim();
    if (cmd.isNotEmpty) {
      final values = cmd.split(' ')
        ..removeWhere((element) => element.isEmpty);
      if (values.isNotEmpty) {
        flutterProcess = values.first;
        if (values.length > 1) {
          arguments = values.sublist(1);
        }
      }
    }
    return frameworkVersion(
      flutterProcess: flutterProcess,
      arguments: arguments,
    );
  }

  /// 获取 Flutter 版本
  Future<String?> frameworkVersion({
    String? flutterProcess,
    List<String> arguments = const <String>[],
  }) async {
    final result = process.runSync(
      flutterProcess ?? 'flutter',
      arguments + ['--version'],
    );
    if (result.exitCode != ExitCode.success.code) {
      return null;
    }
    final output = (result.stdout as String?)?.trim() ?? '';
    final flutterVersionRegex = RegExp(r'Flutter (\d+.\d+.\d+)');
    final match = flutterVersionRegex.firstMatch(output);
    return match?.group(1);
  }

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

  /// 获取 Flutter 的 SDK 路径
  ///
  /// 如: /Users/lxf/fvm/versions/3.29.0
  String? sdkPath(String? flutterCmd) {
    var flutterCmdStr = (flutterCmd ?? '').trim();
    if (flutterCmdStr.isEmpty) {
      flutterCmdStr = osInterface.which('flutter') ?? '';
    }
    if (flutterCmdStr.isEmpty) {
      return null;
    }
    if (flutterCmdStr.startsWith('fvm')) {
      // fvm spawn 3.24.5
      final version = flutterCmdStr.split(' ').last;
      final fvmDirPath = osInterface.absolute('~/fvm');
      return p.join(fvmDirPath, 'versions', version);
    } else {
      // /Users/lxf/fvm/default/bin/flutter
      final flutterPath = osInterface.which(flutterCmdStr);
      if (flutterPath == null) {
        return null;
      }
      // /Users/lxf/fvm/default
      final dirPath = File(flutterPath).parent.parent.path;
      // default 是替身，需要获取软链接的真实路径
      return Directory(dirPath).resolveSymbolicLinksSync();
    }
  }

  /// 删除缓存（snapshot、stamp）
  ///
  /// [flutterCmd]: flutter 命令
  /// [packageName]: 包名（如: flutter_tool）
  bool removeCache(
    String? flutterCmd, {
    required String packageName,
  }) {
    if (packageName.isEmpty) {
      Log.error('包名不能为空');
      return false;
    }
    final flutterSDKPath = sdkPath(flutterCmd);
    if (flutterSDKPath == null) {
      Log.error('无法获取 Flutter SDK 路径');
      return false;
    }
    final cacheDirPath = p.join(
      flutterSDKPath,
      'bin',
      'cache',
    );
    final cacheSuffixes = [
      'snapshot',
      'stamp',
    ];
    for (final suffix in cacheSuffixes) {
      final path = p.join(cacheDirPath, '$packageName.$suffix');
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    return true;
  }
}
