import 'package:condor_cli/src/command.dart';
import 'package:condor_cli/src/commands/copilot/freedom/freedom.dart';
import 'package:condor_cli/src/commands/flutter/version/flutter_version.dart';

/// Copilot命令
class CopilotCommand extends CondorCommand {
  /// Copilot命令构造函数
  CopilotCommand() {
    addSubcommand(FlutterVersionCommand());
    addSubcommand(CopilotFreedomCommand());
  }

  @override
  final String description = 'Copilot相关的命令';

  @override
  final String name = 'copilot';
}
