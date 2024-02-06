import 'package:condor_cli/src/utils/utils.dart';

/// 环境管理单例
CondorEnv env = CondorEnv();

/// 环境管理
class CondorEnv {
  /// 检查java环境
  bool checkJava() {
    final isInstalled = javaPath() != null;
    if (!isInstalled) {
      Log.error('没有找到java环境，请先安装java环境');
    }
    return isInstalled;
  }

  /// java路径
  String? javaPath() {
    return osInterface.which('java');
  }
}
