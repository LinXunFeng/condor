import 'package:condor_cli/src/command_runner.dart';
import 'package:condor_cli/src/common.dart';
import 'package:condor_cli/src/utils/utils.dart';

/// 命令的抽象类
abstract class CondorCommand extends Command<int> {
  @override
  CondorCommandRunner? get runner => super.runner as CondorCommandRunner?;

  /// 参数解析结果（测试用）
  @visibleForTesting
  ArgResults? testArgResults;

  /// 参数解析结果
  ArgResults get results => testArgResults ?? argResults!;

  /// 获取 option 的值
  String stringOption(String option) {
    return results.wasParsed(option) ? results[option] as String : '';
  }

  /// 输出成功信息
  void logSuccess() {
    Log.success('🥳 大功告成 - $name');
  }
}
