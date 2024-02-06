import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:condor_cli/src/command.dart';
import 'package:condor_cli/src/common.dart';
import 'package:condor_cli/src/models/config_model.dart';
import 'package:condor_cli/src/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// 上传命令
class UploadCommand extends CondorCommand {
  /// 上传命令构造函数
  UploadCommand() {
    argParser
      ..addOption('config', abbr: 'c', help: '指定配置文件的路径')
      ..addFlag('add', abbr: 'a', help: '添加配置文件');
  }

  @override
  final String description = '上传符号表';

  @override
  final String name = 'upload';

  @override
  FutureOr<int>? run() async {
    if (!results.wasParsed('config')) {
      Log.error('请使用 -c 指定配置文件的路径');
      return ExitCode.usage.code;
    }
    Log.info('upload -- config: ${results['config']}');
    final configPath = results['config'] as String;
    // 读取配置文件
    final yamlText = File(configPath).readAsStringSync();
    final yaml = loadYaml(yamlText) as YamlMap;
    final map = json.decode(json.encode(yaml)) as Map<String, dynamic>? ?? {};
    final config = Config.fromJson(map);
    final symbolZipPath = config.symbolZipPath;
    final symbolZipFile = File(symbolZipPath);
    if (!symbolZipFile.existsSync()) {
      Log.error('请在配置文件中正确指定符号表zip文件的路径');
      return ExitCode.usage.code;
    }
    final buglyConfig = config.bugly;
    // 检验参数
    if (buglyConfig.appId.isEmpty ||
        buglyConfig.appKey.isEmpty ||
        buglyConfig.bundleId.isEmpty ||
        buglyConfig.jarPath.isEmpty) {
      Log.error('请在配置文件中正确指定 bugly 的参数');
      return ExitCode.usage.code;
    }

    // 创建 temp 目录
    final symbolZipDirPath = p.dirname(symbolZipPath);
    final symbolTempDirPath = p.join(symbolZipDirPath, 'temp.dSYM');
    final tempDir = Directory(symbolTempDirPath);
    if (tempDir.existsSync()) {
      // 存在就删除，重新创建
      tempDir.deleteSync(recursive: true);
    }
    tempDir.createSync(recursive: true);

    // 解压
    await extractFileToDisk(
      symbolZipPath,
      tempDir.path,
    );

    // 上传
    final symbols = config.symbols;
    if (symbols.isEmpty) {
      // 空则上传全部
      symbols.addAll(tempDir.listSync().map((e) => p.basename(e.path)));
    }
    final uploadFutures = <Future<CondorProcessResult>>[];
    for (final symbolName in symbols) {
      final symbolFilePath = p.join(tempDir.path, symbolName);
      uploadFutures.add(
        bugly.uploadSymbol(
          jarPath: buglyConfig.jarPath,
          appId: buglyConfig.appId,
          appKey: buglyConfig.appKey,
          bundleId: buglyConfig.bundleId,
          version: config.version,
          platform: config.platform,
          symbolFilePath: symbolFilePath,
        ),
      );
    }
    final uploadResults = await Future.wait(uploadFutures);
    for (final result in uploadResults) {
      if (result.exitCode != 0) {
        Log.error('上传失败: ${result.stderr}');
      } else {
        Log.info('上传成功: ${result.stdout}');
      }
    }

    // 删除 temp 目录
    tempDir.deleteSync(recursive: true);
    return ExitCode.success.code;
  }
}
