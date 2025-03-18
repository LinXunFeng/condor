import 'dart:io';

import 'package:condor_cli/src/utils/log.dart';
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
  
  /// 获取用户主目录
  String? getHomeDirectory() {
    // 尝试获取环境变量
    String? homePath;
    
    if (Platform.isWindows) {
      // Windows 系统使用 USERPROFILE 环境变量
      homePath = Platform.environment['USERPROFILE'];
    } else {
      // macOS 和 Linux 系统使用 HOME 环境变量
      homePath = Platform.environment['HOME'];
    }
    
    // 如果无法通过环境变量获取，尝试其他方式
    if (homePath == null) {
      try {
        if (Platform.isWindows) {
          // 在 Windows 上可以尝试使用 SystemRoot 或 HOMEDRIVE + HOMEPATH
          final homeDrive = Platform.environment['HOMEDRIVE'];
          final homePath = Platform.environment['HOMEPATH'];
          if (homeDrive != null && homePath != null) {
            return '$homeDrive$homePath';
          }
        } else {
          // 在类 Unix 系统上可以尝试使用 /etc/passwd 文件
          // 但这超出了当前需求，暂不实现
        }
      } catch (e) {
        Log.error('获取用户主目录时出错: $e');
      }
    }
    
    return homePath;
  }

  /// 绝对路径
  String absolute(String path) {
    // Dart 不支持 ~/Downloads 这种路径简写
    // https://github.com/dart-lang/path/issues/1
    // https://github.com/dart-lang/sdk/issues/18466
    var absolutePath = path;
    if (path.startsWith('~')) {
      // 使用 getHomeDirectory 方法获取家目录路径
      final homePath = getHomeDirectory();
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
