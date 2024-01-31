import 'dart:async';

import 'package:condor_cli/src/command.dart';
import 'package:condor_cli/src/common.dart';

class UploadCommand extends CondorCommand {
  UploadCommand() {
    argParser.addOption('config', abbr: 'c', help: '指定配置文件的路径');
    argParser.addFlag('add', abbr: 'a', help: '添加配置文件');
  }

  @override
  final String description = '上传符号表';

  @override
  final String name = 'upload';

  @override
  FutureOr<int>? run() {
    print('upload -- config: ${results['config']}');
    return ExitCode.success.code;
  }
}
