import 'dart:async';
import 'dart:io';

import 'package:condor_cli/src/command.dart';
import 'package:condor_cli/src/utils/utils.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as p;

/// xctoolchain 拷贝
///
/// 将指定的 Xcode 版本的 XcodeDefault.xctoolchain 拷贝至
/// ~/Library/Developer/Toolchains，并更新 ToolchainInfo.plist
class OptimizeBuildXcToolchainCopyCommand extends CondorCommand {
  /// cc 重写向
  OptimizeBuildXcToolchainCopyCommand() {
    argParser.addOption(
      'xcode',
      abbr: 'x',
      help: 'xcode 在 Applications 下的名字，如 Xcode-15.4.0.app, 就使用 Xcode-15.4.0',
    );
  }

  @override
  String get description => 'xctoolchain 拷贝';

  @override
  String get name => 'xctoolchain-copy';

  /// xcode 名
  String get xcode => stringOption('xcode');

  @override
  FutureOr<int>? run() async {
    if (xcode.isEmpty) {
      Log.error('没有找到 Xcode, 请通过 --xcode 指定 xcode 名');
      return ExitCode.usage.code;
    }

    // 获取 xctoolchain 路径
    // /Applications/Xcode-15.4.0.app
    final xcToolchainPath = p.join(
      '/Applications',
      '$xcode.app',
      'Contents',
      'Developer',
      'Toolchains',
      'XcodeDefault.xctoolchain',
    );
    if (!Directory(xcToolchainPath).existsSync()) {
      Log.error('没有找到 $xcode 的 xctoolchain 路径');
      return ExitCode.usage.code;
    }

    final toolChainsPath = osInterface.absolute(
      '~/Library/Developer/Toolchains',
    );
    await Directory(toolChainsPath).create(recursive: true);
    // 拷贝到 toolChainsPath下，将改名，如: Xcode-15.4.0.xctoolchain
    final destPath = p.join(
      toolChainsPath,
      '$xcode.xctoolchain',
    );
    final destDirectory = Directory(destPath);
    if (destDirectory.existsSync()) {
      // 已经存在，则删除
      await destDirectory.delete(recursive: true);
    }
    Log.info('请耐心等待...');
    await Process.run(
      'cp',
      [
        '-r',
        xcToolchainPath,
        destPath,
      ],
    );

    // ToolchainInfo.plist
    // /usr/libexec/PlistBuddy -c "Add CompatibilityVersion integer 2" Xcode15.4.xctoolchain/ToolchainInfo.plist
    // /usr/libexec/PlistBuddy -c "Set Identifier clang.Xcode15.4" Xcode15.4.xctoolchain/ToolchainInfo.plist
    final toolchainInfoPath = p.join(
      destPath,
      'ToolchainInfo.plist',
    );
    if (!File(toolchainInfoPath).existsSync()) {
      Log.error('没有找到 ToolchainInfo.plist 文件');
      return ExitCode.usage.code;
    }

    var result = await plistBuddy.setCompatibilityVersion(
      2,
      toolchainInfoPath,
    );
    if (!result.success) {
      Log.error('修改 ToolchainInfo.plist 失败 (CompatibilityVersion)');
      return ExitCode.software.code;
    }
    result = await plistBuddy.setIdentifier(
      xcode,
      toolchainInfoPath,
    );
    if (!result.success) {
      Log.error('修改 ToolchainInfo.plist 失败 (Identifier)');
      return ExitCode.software.code;
    }

    logSuccess();
    return ExitCode.success.code;
  }
}

/**
"args": [
  "optimize-build",
  "xctoolchain-copy",
  "--xcode",
  "Xcode-15.4.0"
]

# 执行命令
condor optimize-build xctoolchain-copy --xcode Xcode-15.4.0
 */
