import 'package:condor_cli/src/command.dart';
import 'package:condor_cli/src/commands/flutter/version/flutter_version.dart';

/// Flutter命令
class FlutterCommand extends CondorCommand {
  /// Flutter命令构造函数
  FlutterCommand() {
    addSubcommand(FlutterVersionCommand());
  }

  @override
  final String description = 'Flutter相关的命令';

  @override
  final String name = 'flutter';
}
