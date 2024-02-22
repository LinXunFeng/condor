import 'dart:async';
import 'dart:io';

import 'package:condor_cli/src/command.dart';
import 'package:condor_cli/src/common.dart';
import 'package:condor_cli/src/utils/utils.dart';

/// Flutter version print 命令
class FlutterVersionPrintCommand extends CondorCommand {
  /// Flutter version print 命令构造函数
  FlutterVersionPrintCommand() {
    argParser.addOption('flutter', abbr: 'f', help: '指定flutter命令');
  }

  @override
  final String description = '输出当前flutter的版本号';

  @override
  final String name = 'print';

  @override
  FutureOr<int>? run() async {
    // 常规使用: flutter version print
    // 指定flutter程序: flutter version print -f "fvm spawn 3.16.0"
    String? flutterProcess;
    var arguments = <String>[];
    if (results.wasParsed('flutter')) {
      // 指定了flutter命令
      final value = (results['flutter'] as String).trim();
      final values = value.split(' ')
        ..removeWhere((element) => element.isEmpty);
      if (values.isEmpty) {
        return ExitCode.usage.code;
      }
      flutterProcess = values.first;
      if (values.length > 1) {
        arguments = values.sublist(1);
      }
    }
    final result = await flutter.frameworkVersion(
      flutterProcess: flutterProcess,
      arguments: arguments,
    );
    stdout.writeln(result ?? '');
    return ExitCode.success.code;
  }
}
