import 'package:condor_cli/src/command_runner.dart';
import 'package:condor_cli/src/common.dart';

/// 命令的抽象类
abstract class CondorCommand extends Command<int> {
  @override
  CondorCommandRunner? get runner => super.runner as CondorCommandRunner?;

  /// 参数解析结果（测试用）
  @visibleForTesting
  ArgResults? testArgResults;

  /// 参数解析结果
  ArgResults get results => testArgResults ?? argResults!;
}
