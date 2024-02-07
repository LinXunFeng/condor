import 'dart:io';

import 'package:condor_cli/src/utils/process.dart';
import 'package:io/io.dart';

/// 操作系统接口单例
OperatingSystemInterface osInterface = OperatingSystemInterface();

/// 操作系统接口
class OperatingSystemInterface {
  /// 对应 which 命令
  String? which(String executableName) {
    final result = process.runSync('which', [executableName]);
    if (result.exitCode != ExitCode.success.code) {
      return null;
    }

    return (result.stdout as String?)?.trim();
  }

  /// 绝对路径
  String absolute(String path) {
    // Dart 不支持 ~/Downloads 这种路径简写
    // https://github.com/dart-lang/path/issues/1
    // https://github.com/dart-lang/sdk/issues/18466
    var absolutePath = path;
    if (path.startsWith('~')) {
      // 通过环境变量取家目录的路径来做替换
      // https://stackoverflow.com/a/32937974/8577739
      final homePath = Platform.environment['HOME'];
      if (homePath != null) {
        if (path.length == 1) {
          absolutePath = homePath;
        } else {
          absolutePath = '$homePath${path.substring(1)}';
        }
      }
    }
    return absolutePath;
  }
}
