import 'dart:io';

/// CondorPlistBuddy 单例
CondorPlistBuddy plistBuddy = CondorPlistBuddy();

/// PlistBuddy 封装
class CondorPlistBuddy {
  /// 执行 PlistBuddy 命令并返回结果
  ///
  /// 返回一个记录，包含：
  /// - success: 命令是否成功执行
  /// - stdout: 命令的标准输出
  /// - stderr: 命令的标准错误输出
  /// - exitCode: 进程的退出代码
  Future<
      ({
        bool success,
        String stdout,
        String stderr,
        int exitCode,
      })> executePlistBuddyCommand(
    String command,
    String plistPath, {
    List<String> additionalArgs = const [],
  }) async {
    final args = [
      '-c',
      command,
      plistPath,
      ...additionalArgs,
    ];

    try {
      final process = await Process.start(
        '/usr/libexec/PlistBuddy',
        args,
      );

      final stdout = await process.stdout
          .transform(
            const SystemEncoding().decoder,
          )
          .join();
      final stderr = await process.stderr
          .transform(
            const SystemEncoding().decoder,
          )
          .join();
      final exitCode = await process.exitCode;

      return (
        success: exitCode == 0,
        stdout: stdout.trim(),
        stderr: stderr.trim(),
        exitCode: exitCode,
      );
    } catch (e) {
      return (
        success: false,
        stdout: '',
        stderr: e.toString(),
        exitCode: -1,
      );
    }
  }

  /// 在 plist 文件中设置 CompatibilityVersion
  Future<
      ({
        bool success,
        String stdout,
        String stderr,
        int exitCode,
      })> setCompatibilityVersion(
    int value,
    String plistPath,
  ) async {
    // 如果有 CompatibilityVersion，则使用 Set
    // 如果没有 CompatibilityVersion，则使用 Add
    // 先检查 plist 文件中是否有 CompatibilityVersion
    const key = 'CompatibilityVersion';
    const compatibilityVersionCommand = 'Print $key';
    final compatibilityVersionResult = await executePlistBuddyCommand(
      compatibilityVersionCommand,
      plistPath,
    );
    if (compatibilityVersionResult.success) {
      // 如果有 CompatibilityVersion，则使用 Set
      return executePlistBuddyCommand(
        'Set $key $value',
        plistPath,
      );
    }
    // 如果没有 CompatibilityVersion，则使用 Add
    return executePlistBuddyCommand(
      'Add $key integer $value',
      plistPath,
    );
  }

  /// 在 plist 文件中设置 Identifier
  Future<
      ({
        bool success,
        String stdout,
        String stderr,
        int exitCode,
      })> setIdentifier(
    String value,
    String plistPath,
  ) {
    return executePlistBuddyCommand(
      'Set Identifier $value',
      plistPath,
    );
  }
}
