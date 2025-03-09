import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:condor_cli/src/command.dart';
import 'package:condor_cli/src/common.dart';
import 'package:condor_cli/src/utils/utils.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

/// Flutter 优化编译
/// 请在 flutter_project/ios 目录下执行
class OptimizeBuildCommand extends CondorCommand {
  /// Flutter 优化编译
  OptimizeBuildCommand() {
    argParser
      ..addOption(
        'flutter',
        abbr: 'f',
        help: 'flutter 命令 (如: flutter 或者 fvm spawn 3.24.5)',
      )
      ..addOption(
        'mode',
        abbr: 'm',
        help: '编译模式 (如: profile 或者 release)',
      )
      ..addOption(
        'config',
        abbr: 'c',
        help: '配置文件路径',
      );
  }

  @override
  String get description => '优化编译';

  @override
  String get name => 'optimize-build';

  /// flutter 命令
  String get flutterCmd => stringOption('flutter');

  /// 配置文件路径
  String get config => stringOption('config');

  /// 编译模式
  String get mode => stringOption('mode');

  @override
  FutureOr<int>? run() async {
    // 获取配置文件路径
    if (config.isEmpty) {
      Log.error('请指定 Rugby 的计划文件路径');
      return ExitCode.usage.code;
    }

    // 判断是否有安装 Rugby
    final rugbyPath = osInterface.which('rugby');
    if (rugbyPath == null) {
      Log.error('请先安装 Rugby');
      return ExitCode.software.code;
    }

    var buildMode = mode;
    if (buildMode.isEmpty) {
      // 取出环境变量 CONDOR_BUILD_MODE
      buildMode = Platform.environment['CONDOR_BUILD_MODE'] ?? '';
    }
    if (buildMode.isEmpty) {
      Log.error('未设置 CONDOR_BUILD_MODE 环境变量，也未指定编译模式');
      return ExitCode.config.code;
    }

    // 根据不同的 CONDOR_BUILD_MODE 获取对应的模式
    if (![
      'profile',
      'release',
    ].contains(buildMode)) {
      Log.error('不支持的 CONDOR_BUILD_MODE: $buildMode');
      return ExitCode.config.code;
    }

    final projectPath = findProjectPath();
    // 执行 rugby 命令
    final iosPath = path.join(
      projectPath,
      'ios',
    );
    final rugbyProcess = await process.start(
      'rugby',
      [
        'plan',
        buildMode,
        '-p',
        config,
      ],
      workingDirectory: iosPath,
    );

    // 实时输出 stdout
    rugbyProcess.stdout
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen(Log.info);

    // 实时输出 stderr
    rugbyProcess.stderr
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen(Log.info);

    // 等待命令执行完成
    final exitCode = await rugbyProcess.exitCode;
    if (exitCode != 0) {
      Log.error('Rugby 命令执行失败');
      return exitCode;
    }

    Log.success('优化编译完成');

    // 伪造 pod_inputs.fingerprint
    // pod_inputs.fingerprint 路径
    final podInputsFingerprintPath = path.join(
      projectPath,
      'build',
      'ios',
      'pod_inputs.fingerprint',
    );

    // 更新 pod_inputs.fingerprint
    await updatePodInputsFingerprint(
      projectPath,
      podInputsFingerprintPath,
    );

    // 复制 Podfile.lock 到 Pods/Manifest.lock
    generateManifestLock(projectPath);

    return ExitCode.success.code;
  }

  /// 查找项目的根路径
  String findProjectPath() {
    // 获取当前路径
    return Directory.current.path;
  }

  /// 计算文件的 MD5
  String calculateFileMd5(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('文件不存在', filePath);
    }
    final bytes = file.readAsBytesSync();
    return md5.convert(bytes).toString();
  }

  /// 更新 pod_inputs.fingerprint
  Future<bool> updatePodInputsFingerprint(
    String projectPath,
    String podInputsFingerprintPath,
  ) async {
    final fileFingerprints = <String, String>{};

    final iosPath = path.join(
      projectPath,
      'ios',
    );

    // 计算 project.pbxproj 的 MD5
    final pbxprojPath = path.join(
      iosPath,
      'Runner.xcodeproj',
      'project.pbxproj',
    );
    fileFingerprints[pbxprojPath] = calculateFileMd5(pbxprojPath);

    // 计算 Podfile 的 MD5
    final podfilePath = path.join(
      iosPath,
      'Podfile',
    );
    fileFingerprints[podfilePath] = calculateFileMd5(podfilePath);

    // 计算 podhelper.rb 的 MD5
    // 使用 getFlutterSdkPath 获取 Flutter SDK 路径
    final flutterSdkPath = flutter.sdkPath(flutterCmd);
    if (flutterSdkPath == null) {
      return false;
    }
    final podhelperPath = path.join(
      flutterSdkPath,
      'packages',
      'flutter_tools',
      'bin',
      'podhelper.rb',
    );
    fileFingerprints[podhelperPath] = calculateFileMd5(
      podhelperPath,
    );

    // 创建 fingerprint JSON
    final fingerprintJson = {
      'files': fileFingerprints,
    };

    // 确保目录存在
    final fingerprintDir = Directory(
      path.dirname(
        podInputsFingerprintPath,
      ),
    );
    if (!fingerprintDir.existsSync()) {
      fingerprintDir.createSync(
        recursive: true,
      );
    }

    // 写入 fingerprint 文件
    File(podInputsFingerprintPath).writeAsStringSync(
      jsonEncode(
        fingerprintJson,
      ),
    );
    return true;
  }

  /// 复制 Podfile.lock 到 Pods/Manifest.lock
  void generateManifestLock(String projectPath) {
    final iosPath = path.join(
      projectPath,
      'ios',
    );

    // 将 Podfile.lock 拷贝到 Pods/Manifest.lock
    final podfileLockPath = path.join(
      iosPath,
      'Podfile.lock',
    );

    final mainfestPath = path.join(
      iosPath,
      'Pods',
      'Manifest.lock',
    );

    // 确保目标目录存在
    final manifestDir = Directory(path.dirname(mainfestPath));
    if (!manifestDir.existsSync()) {
      manifestDir.createSync(recursive: true);
    }

    // 复制文件，如果目标文件存在则覆盖
    File(podfileLockPath).copySync(mainfestPath);
  }
}

/**
"cwd": "path/to/flutter_project/ios",
"args": [
  "optimize-build",
  "--config",
  "path/to/rugby/plans.yml",
  "--flutter",
  "fvm spawn 3.24.5"
]

1、进入 flutter 项目的 ios 目录
cd path/to/flutter_project/ios
2、设置环境变量
export CONDOR_BUILD_MODE='release'
3、执行命令
condor optimize-build --config path/to/rugby/plans.yml --flutter fvm spawn 3.24.5
 */
