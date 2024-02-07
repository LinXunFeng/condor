import 'dart:async';
import 'dart:io';

import 'package:condor_cli/src/command.dart';
import 'package:condor_cli/src/common.dart';
import 'package:condor_cli/src/utils/utils.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// 初始化命令
///
/// condor init -o ~/Downloads/condor -r ~/Downloads/condor/固定配置.yaml
class InitCommand extends CondorCommand {
  /// 初始化命令构造函数
  InitCommand() {
    argParser
      ..addOption('ref', abbr: 'r', help: '指定固定配置文件的路径')
      ..addOption('out', abbr: 'o', help: '指定配置文件的输出目录路径');
  }

  @override
  final String description = '创建配置文件';

  @override
  final String name = 'init';

  @override
  FutureOr<int>? run() {
    Log.info('初始化配置文件');

    var refMap = <String, dynamic>{};
    if (results.wasParsed('ref')) {
      var path = results['ref'] as String;
      path = osInterface.absolute(path);
      final refFile = File(path);
      if (refFile.existsSync()) {
        refMap = yaml.loadToMap(path);
      }
    }

    var dir = Directory.current;
    if (results.wasParsed('out')) {
      var path = results['out'] as String;
      path = osInterface.absolute(path);
      dir = Directory(path);
    }
    final configYamlFile = file.getConfigYamlFile(cwd: dir);
    if (!configYamlFile.existsSync()) {
      // 配置文件不存在就创建一个
      Log.info('配置文件不存在，创建一个空白文件');
      configYamlFile.createSync(recursive: true);
    }

    final map = <String, dynamic>{
      'symbol_zip_path': '', // 符号号压缩包路径
      'symbols': <String>[], // 指定仅上传的符号表，不指定则上传所有
      'bundle_id': '', // app 的 bundleId
      'version': '', // app的版本号
      'platform': 'IOS', // IOS / Android
      'flutter': {
        'version': '', // Flutter 版本
      },
      'bugly': {
        'app_id': '',
        'app_key': '',
        'jar_path': '', // 符号表上传工具中的buglyqq-upload-symbol.jar路径
      },
    }..addAll(refMap);
    // 转模型时用得到
    // final jsonStr = json.encode(map);
    // print(jsonStr);

    Log.info('将配置写入文件');
    final yamlEditor = YamlEditor('')..update([], map);
    configYamlFile.writeAsStringSync(yamlEditor.toString(), flush: true);
    return ExitCode.success.code;
  }
}
