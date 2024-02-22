import 'package:condor_cli/src/command.dart';
import 'package:condor_cli/src/commands/flutter/version/version.dart';

/// Flutter version 命令
class FlutterVersionCommand extends CondorCommand {
  /// Flutter version 命令构造函数
  FlutterVersionCommand() {
    addSubcommand(FlutterVersionPrintCommand());
  }

  @override
  final String description = 'Flutter version相关的命令';

  @override
  final String name = 'version';
}
