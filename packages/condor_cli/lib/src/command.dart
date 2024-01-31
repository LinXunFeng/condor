import 'package:condor_cli/src/command_runner.dart';
import 'package:condor_cli/src/common.dart';


abstract class CondorCommand extends Command<int> {
  @override
  CondorCommandRunner? get runner => super.runner as CondorCommandRunner?;

  @visibleForTesting
  ArgResults? testArgResults;

  ArgResults get results => testArgResults ?? argResults!;
}
