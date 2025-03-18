import 'dart:async';
import 'dart:io';

import 'package:condor_cli/src/command.dart';
import 'package:condor_cli/src/common.dart';
import 'package:condor_cli/src/utils/log.dart';
import 'package:condor_cli/src/utils/os.dart';
import 'package:path/path.dart' as path;

/// Copilot 解除限制
class CopilotFreedomCommand extends CondorCommand {
  @override
  String get description => '解除 Copilot 的限制';

  @override
  String get name => 'freedom';

  @override
  FutureOr<int>? run() async {
    // https://github.com/cline/cline/issues/2186#issuecomment-2727010228
    Log.info('正在执行 Copilot Freedom 命令...');

    // 查找 VS Code 扩展目录
    final extensionsPath = findVSCodeExtensionPath();
    if (extensionsPath == null) {
      Log.error('无法找到 VS Code 扩展目录');
      return ExitCode.software.code;
    }

    Log.info('找到 VS Code 扩展目录: $extensionsPath');

    // 查找 Copilot Chat 扩展
    final copilotExtPath = findCopilotChatExtension(extensionsPath);
    if (copilotExtPath == null) {
      Log.error('未找到 GitHub Copilot Chat 扩展，请确认已安装该扩展');
      return ExitCode.software.code;
    }

    Log.info('找到 GitHub Copilot Chat 扩展: $copilotExtPath');

    // 修改扩展文件
    final success = await modifyExtensionFile(copilotExtPath);
    if (!success) {
      Log.error('修改扩展文件失败');
      return ExitCode.software.code;
    }

    // Log.success('成功移除 Copilot Chat 扩展的限制！');
    return ExitCode.success.code;
  }

  /// 查找 VS Code 扩展目录
  String? findVSCodeExtensionPath() {
    final home = osInterface.getHomeDirectory();

    if (home == null) {
      Log.error('无法获取用户主目录');
      return null;
    }

    String extensionsPath;
    if (Platform.isWindows) {
      // Windows
      extensionsPath = path.join(
        home,
        '.vscode',
        'extensions',
      );
    } else if (Platform.isMacOS) {
      // macOS
      extensionsPath = path.join(
        home,
        '.vscode',
        'extensions',
      );

      // 如果主目录不存在，尝试使用 Library/Application Support 路径
      if (!Directory(extensionsPath).existsSync()) {
        extensionsPath = path.join(
          home,
          'Library',
          'Application Support',
          'Code',
          'User',
          'extensions',
        );
      }
    } else {
      // Linux
      extensionsPath = path.join(
        home,
        '.vscode',
        'extensions',
      );
    }

    // 检查路径是否存在
    final directory = Directory(extensionsPath);
    if (!directory.existsSync()) {
      Log.error('扩展目录不存在: $extensionsPath');
      return null;
    }

    return extensionsPath;
  }

  /// 查找 Copilot Chat 扩展
  String? findCopilotChatExtension(String extensionsPath) {
    final directory = Directory(extensionsPath);

    try {
      // 查找 github.copilot-chat-* 目录
      final entities = directory.listSync();
      for (final entity in entities) {
        if (entity is Directory) {
          final name = path.basename(entity.path);
          if (name.startsWith('github.copilot-chat-')) {
            return entity.path;
          }
        }
      }

      // 也尝试查找 Insiders 版本
      for (final entity in entities) {
        if (entity is Directory) {
          final name = path.basename(entity.path);
          if (name.startsWith('github.copilot-chat-insiders-')) {
            return entity.path;
          }
        }
      }

      Log.error('未找到 GitHub Copilot Chat 扩展');
      return null;
    } catch (e) {
      Log.error('查找扩展时出错: $e');
      return null;
    }
  }

  /// 修改扩展文件
  Future<bool> modifyExtensionFile(String extensionPath) async {
    final extensionJsPath = path.join(extensionPath, 'dist', 'extension.js');
    final file = File(extensionJsPath);

    // 检查文件是否存在
    if (!file.existsSync()) {
      Log.error('文件不存在: $extensionJsPath');
      return false;
    }

    try {
      // 读取文件内容
      String content = await file.readAsString();

      // 创建备份
      final backupPath = '$extensionJsPath.backup';
      final backupFile = File(backupPath);
      if (!backupFile.existsSync()) {
        await file.copy(backupPath);
        Log.info('已创建文件备份: $backupPath');
      }

      // 简化查找逻辑，直接查找并删除 x-onbehalf-extension-id 部分
      // 使用正则表达式直接查找包含 x-onbehalf-extension-id 的部分
      final targetPattern = RegExp(r',\s*"x-onbehalf-extension-id"\s*:`\${A}/\${c}`');
      
      if (targetPattern.hasMatch(content)) {
        content = content.replaceAll(targetPattern, '');
        Log.info('成功找到并移除了 x-onbehalf-extension-id 头');
      } else {
        // 尝试查找可能的变体
        final altTargetPattern = RegExp(r',\s*"x-onbehalf-extension-id"\s*:\s*`[^`]+`');
        
        if (altTargetPattern.hasMatch(content)) {
          content = content.replaceAll(altTargetPattern, '');
          Log.info('成功找到并移除了 x-onbehalf-extension-id 头(变体)');
        } else {
          Log.error('未找到 x-onbehalf-extension-id 部分，请确认扩展版本是否兼容');
          return false;
        }
      }

      // 写入修改后的内容
      await file.writeAsString(content);
      Log.success('解除限制成功，请重启 VSCode 以使修改生效');
      return true;
    } catch (e) {
      Log.error('解除限制失败: $e');
      return false;
    }
  }
}
