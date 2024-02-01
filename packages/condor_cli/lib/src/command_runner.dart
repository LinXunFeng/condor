import 'package:condor_cli/src/commands/doctor.dart';
import 'package:condor_cli/src/commands/init.dart';
import 'package:condor_cli/src/commands/upload.dart';
import 'package:condor_cli/src/common.dart';
import 'package:condor_cli/src/utils/utils.dart';

/// 包名
const packageName = 'condor_cli';

/// 可执行程序名
const executableName = 'condor';

/// 该CLI的描述
const description = 'condor让你轻松上传符号表';

/// condor命令行运行器
class CondorCommandRunner extends CompletionCommandRunner<int> {
  /// condor命令行运行器构造函数
  /// 添加所有命令
  CondorCommandRunner() : super(executableName, description) {
    addCommand(InitCommand());
    addCommand(DoctorCommand());
    addCommand(UploadCommand());
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      return await runCommand(parse(args)) ?? ExitCode.success.code;
    } on UsageException catch (e) {
      Log.error(e.message);
      Log.info(e.usage);
      return ExitCode.usage.code;
    } catch (e) {
      Log.error(e.toString());
      return ExitCode.software.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) {
    // print('topLevelResults -- $topLevelResults');
    return super.runCommand(topLevelResults);
  }
}
