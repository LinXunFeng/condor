import 'dart:async';

import 'package:condor_cli/src/command.dart';
import 'package:condor_cli/src/common.dart';
import 'package:condor_cli/src/utils/utils.dart';

/// 诊断命令
class DoctorCommand extends CondorCommand {
  /// 诊断命令构造函数
  DoctorCommand();

  @override
  final String description = '环境信息';

  @override
  final String name = 'doctor';

  @override
  FutureOr<int>? run() {
    final javaPath = osInterface.which('java');
    if (javaPath == null) {
      Log.error('没有找到java环境，请先安装java环境');
      return ExitCode.unavailable.code;
    }

    Log.info('''
====== Doctor ======

JAVA路径: $javaPath

====== End ======
''');
    return ExitCode.success.code;
  }
}
