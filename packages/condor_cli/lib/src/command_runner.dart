
import 'package:condor_cli/src/commands/doctor.dart';
import 'package:condor_cli/src/commands/init.dart';
import 'package:condor_cli/src/commands/upload.dart';
import 'package:condor_cli/src/common.dart';
import 'package:condor_cli/src/utils/utils.dart';

const packageName = 'condor_cli';
const executableName = 'condor';
const description = 'condor让你轻松上传符号表';

class CondorCommandRunner extends CompletionCommandRunner<int> {
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
      print(e);
      return ExitCode.software.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) {
    // print('topLevelResults -- $topLevelResults');
    return super.runCommand(topLevelResults);
  }
}
