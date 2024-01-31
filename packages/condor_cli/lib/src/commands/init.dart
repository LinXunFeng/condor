import 'dart:async';

import 'package:condor_cli/src/command.dart';
import 'package:condor_cli/src/common.dart';

class InitCommand extends CondorCommand {
  InitCommand();

  @override
  final String description = '创建配置文件';

  @override
  final String name = 'init';

  @override
  FutureOr<int>? run() {
    print('init -- 创建配置文件');
    return ExitCode.success.code;
  }
}
