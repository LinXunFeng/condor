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
}
