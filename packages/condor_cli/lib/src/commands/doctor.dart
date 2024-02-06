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
    Log.info('''
====== Doctor ======

Java路径: ${env.javaPath() ?? '没有找到Java环境'}

====== End ======
''');
    return ExitCode.success.code;
  }
}
