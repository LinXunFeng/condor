import 'dart:async';
import 'dart:io';

import 'package:condor_cli/src/command.dart';
import 'package:condor_cli/src/common.dart';
import 'package:condor_cli/src/utils/utils.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// 初始化命令
class InitCommand extends CondorCommand {
  /// 初始化命令构造函数
  InitCommand() {
    argParser.addOption('path', abbr: 'p', help: '指定配置文件的路径');
  }

  @override
  final String description = '创建配置文件';

  @override
  final String name = 'init';

  @override
  FutureOr<int>? run() {
    Log.info('初始化配置文件');

    var dir = Directory.current;
    if (results.wasParsed('path')) {
      final path = results['path'] as String;
      dir = Directory(path);
    }
    final configYamlFile = file.getConfigYamlFile(cwd: dir);
    if (!configYamlFile.existsSync()) {
      // 配置文件不存在就创建一个
      Log.info('配置文件不存在，创建一个');
      configYamlFile.createSync(recursive: true);
    }

    final map = <String, dynamic>{
      'symbolZipPath': '',
      'symbols': '',
      'version': '',
      'platform': 'ios', // ios / android
      'bugly': {
        'appId': '',
        'appKey': '',
        'bundleId': '',
        'jarPath': '',
      },
    };

    final yamlEditor = YamlEditor('')..update([], map);
    configYamlFile.writeAsStringSync(yamlEditor.toString(), flush: true);
    return ExitCode.success.code;
  }
}
