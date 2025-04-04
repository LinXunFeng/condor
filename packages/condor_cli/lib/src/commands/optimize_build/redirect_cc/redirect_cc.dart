import 'dart:async';
import 'dart:io';

import 'package:condor_cli/src/command.dart';
import 'package:condor_cli/src/utils/utils.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as p;

/// cc 重写向
///
/// 修改完成后，设置 CONDOR_TOOLCHAINS 环境变量为 Xcode-15.4.0，
/// 在运行到 cc 命令时，会将其设置给 TOOLCHAINS 来指定 xctoolchain
class OptimizeBuildRedirectCCCommand extends CondorCommand {
  /// cc 重写向
  OptimizeBuildRedirectCCCommand() {
    argParser.addOption(
      'flutter',
      abbr: 'f',
      help: 'flutter 命令 (如: flutter 或者 fvm spawn 3.24.5)',
    );
  }

  @override
  String get description => 'cc 重写向';

  @override
  String get name => 'redirect-cc';

  /// flutter 命令
  String get flutterCmd => stringOption('flutter');

  /// Flutter SDK 路径
  String get flutterSDKPath => flutter.sdkPath(flutterCmd) ?? '';

  @override
  FutureOr<int>? run() async {
    if (flutterSDKPath.isEmpty) {
      Log.error('没有找到 Flutter SDK, 请通过 --flutter 指定 flutter 命令');
      return ExitCode.usage.code;
    }
    // 修改 xcode.dart
    final macosDir = p.join(
      flutterSDKPath,
      'packages',
      'flutter_tools',
      'lib',
      'src',
      'macos',
    );
    // 1. 获取 flutter 的 xcode.dart 文件路径
    final xcodeDartPath = p.join(
      macosDir,
      'xcode.dart',
    );
    if (!File(xcodeDartPath).existsSync()) {
      Log.error('没有找到 xcode.dart 文件');
      return ExitCode.usage.code;
    }

    Log.info('请耐心等待...');
    // 2. 修改 xcode.dart 文件
    final xcodeDartFile = File(xcodeDartPath);
    final xcodeDartContent = await xcodeDartFile.readAsString();
    final xcodeDartLines = xcodeDartContent.split('\n');
    // 找到 import '../cache.dart';
    // 在它的下一行插入 import '../globals.dart';
    final importIndex = xcodeDartLines.indexWhere(
      (line) => line.contains("import '../globals.dart';"),
    );
    if (importIndex == -1) {
      // 还没有添加
      final importLineIndex = xcodeDartLines.lastIndexWhere(
        (line) => line.contains("import '"),
      );
      if (importLineIndex == -1) {
        Log.error('没有找到 import 语句');
        return ExitCode.usage.code;
      }
      xcodeDartLines.insert(
        importLineIndex + 1,
        "import '../globals.dart';",
      );
    }

    // 找到 Future<RunResult> cc(List<String> args) => _run('cc', args); 注释掉
    // 在下一行添加新的 cc 方法
    final ccLineIndex = xcodeDartLines.indexWhere(
      (line) => line.contains('Future<RunResult> cc(List<String> args)'),
    );
    if (ccLineIndex == -1) {
      Log.error('没有找到 cc 方法');
      return ExitCode.usage.code;
    }
    if (xcodeDartLines[ccLineIndex].startsWith('//')) {
      Log.error('cc 方法已经被注释掉了');
      return ExitCode.usage.code;
    }
    // 注释掉原来的 cc 方法
    xcodeDartLines[ccLineIndex] = '// ${xcodeDartLines[ccLineIndex]}';
    // 在下一行添加新的 cc 方法
    xcodeDartLines.insert(
      ccLineIndex + 1,
      r"""
  Future<RunResult> cc(List<String> args) {
    final String condorToolchains = platform.environment['CONDOR_TOOLCHAINS'] ?? '';
    final Map<String, String> environment = <String, String>{
      if (condorToolchains.isNotEmpty) "TOOLCHAINS": condorToolchains,
    };
    _run('--find', <String>['cc'], environment: environment).then((RunResult result) {
      printStatus(
        '\n[condor] find cc: ${result.stdout}\n',
      );
    });
    return _run('cc', args, environment: environment);
  }
""",
    );

    // 注释掉原来的 _run 方法
    final runLineIndex = xcodeDartLines.indexWhere(
      (line) => line.contains('Future<RunResult> _run'),
    );
    if (runLineIndex == -1) {
      Log.error('没有找到 _run 方法');
      return ExitCode.usage.code;
    }
    // Comment out original _run method instead of removing it
    for (var i = runLineIndex; i < runLineIndex + 3; i++) {
      if (i < xcodeDartLines.length) {
        xcodeDartLines[i] = '// ${xcodeDartLines[i]}';
      }
    }
    // 添加新的 _run 方法
    xcodeDartLines.insert(
      runLineIndex + 4,
      '''
  Future<RunResult> _run(String command, List<String> args, {Map<String, String>? environment}) {
    return _processUtils.run(<String>[...xcrunCommand(), command, ...args], throwOnError: true, environment: environment);
  }
''',
    );

    // 写入文件
    await xcodeDartFile.writeAsString(xcodeDartLines.join('\n'));

    // 删除 flutter_tools 缓存
    // flutter_tools.snapshot
    // flutter_tools.stamp
    flutter.removeCache(
      flutterCmd,
      packageName: 'flutter_tools',
    );

    // 重新生成 flutter_tools 缓存
    await flutter.version(
      flutterCmd,
    );

    logSuccess();
    return ExitCode.success.code;
  }
}

/**
"args": [
  "optimize-build",
  "redirect-cc",
  "--flutter",
  "fvm spawn 3.24.5"
]

# 执行命令
condor optimize-build redirect-cc --flutter fvm spawn 3.24.5
 */
