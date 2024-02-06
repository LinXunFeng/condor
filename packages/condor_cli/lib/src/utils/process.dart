import 'dart:io';

import 'package:meta/meta.dart';

CondorProcess process = CondorProcess();

/// 系统命令执行
class CondorProcess {
  /// 构造函数
  CondorProcess({
    ProcessWrapper? processWrapper,
  }) : processWrapper = processWrapper ?? ProcessWrapper();

  /// 包装
  final ProcessWrapper processWrapper;
  Future<CondorProcessResult> run(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
    Map<String, String>? environment,
    String? workingDirectory,
  }) async {
    return processWrapper.run(
      executable,
      arguments,
      runInShell: runInShell,
      environment: environment,
      workingDirectory: workingDirectory,
    );
  }

  CondorProcessResult runSync(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
    Map<String, String>? environment,
    String? workingDirectory,
  }) {
    return processWrapper.runSync(
      executable,
      arguments,
      runInShell: runInShell,
      environment: environment,
      workingDirectory: workingDirectory,
    );
  }

  Future<Process> start(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
    Map<String, String>? environment,
  }) {
    return processWrapper.start(
      executable,
      arguments,
      runInShell: runInShell,
      environment: environment,
    );
  }
}

class CondorProcessResult {
  const CondorProcessResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final dynamic stdout;
  final dynamic stderr;
}

@visibleForTesting
class ProcessWrapper {
  Future<CondorProcessResult> run(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
    Map<String, String>? environment,
    String? workingDirectory,
  }) async {
    final result = await Process.run(
      executable,
      arguments,
      environment: environment,
      runInShell: runInShell,
      workingDirectory: workingDirectory,
    );
    return CondorProcessResult(
      exitCode: result.exitCode,
      stdout: result.stdout,
      stderr: result.stderr,
    );
  }

  CondorProcessResult runSync(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
    Map<String, String>? environment,
    String? workingDirectory,
  }) {
    final result = Process.runSync(
      executable,
      arguments,
      environment: environment,
      runInShell: runInShell,
      workingDirectory: workingDirectory,
    );
    return CondorProcessResult(
      exitCode: result.exitCode,
      stdout: result.stdout,
      stderr: result.stderr,
    );
  }

  Future<Process> start(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
    Map<String, String>? environment,
  }) {
    return Process.start(
      executable,
      arguments,
      runInShell: runInShell,
      environment: environment,
    );
  }
}
