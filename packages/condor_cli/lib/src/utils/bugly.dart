import 'package:condor_cli/src/common.dart';
import 'package:condor_cli/src/utils/utils.dart';

/// Bugly 管理单例
CondorBugly bugly = CondorBugly();

/// Bugly 管理
class CondorBugly {
  /// 上传符号表
  Future<CondorProcessResult> uploadSymbol({
    required String jarPath,
    required String appId,
    required String appKey,
    required String bundleId,
    required String version,
    required String platform,
    required String symbolFilePath,
  }) {
    if (!env.checkJava()) {
      return Future.value(
        CondorProcessResult(
          exitCode: ExitCode.unavailable.code,
          stdout: '',
          stderr: '没有Java环境, 请先安装Java环境',
        ),
      );
    }
    return process.run(
      'java',
      _arguments(
        jarPath: jarPath,
        appId: appId,
        appKey: appKey,
        bundleId: bundleId,
        version: version,
        platform: platform,
        symbolFilePath: symbolFilePath,
      ),
    );
  }

  /// 上传符号表(同步)
  // CondorProcessResult uploadSymbolSync({
  //   required String jarPath,
  //   required String appId,
  //   required String appKey,
  //   required String bundleId,
  //   required String version,
  //   required String platform,
  //   required String symbolFilePath,
  // }) {
  //   return process.runSync(
  //     'java',
  //     _arguments(
  //       jarPath: jarPath,
  //       appId: appId,
  //       appKey: appKey,
  //       bundleId: bundleId,
  //       version: version,
  //       platform: platform,
  //       symbolFilePath: symbolFilePath,
  //     ),
  //   );
  // }

  /// 参数
  List<String> _arguments({
    required String jarPath,
    required String appId,
    required String appKey,
    required String bundleId,
    required String version,
    required String platform,
    required String symbolFilePath,
  }) {
    return [
      '-jar',
      jarPath,
      '-appid',
      appId,
      '-appkey',
      appKey,
      '-bundleid',
      bundleId,
      '-version',
      version,
      '-platform',
      platform,
      '-inputSymbol',
      symbolFilePath,
    ];
  }
}


// final r = await http.head(
//   Uri.tryParse(
//     'https://bugly.qq.com/v2/sdk?id=d796e9d7-0423-422f-9eb9-63b6e16ef4f9',
//   )!,
//   // Uri.tryParse(
//   //   'https://bugly.qq.com/v2/sdk?id=f67d1ca3-5db9-43d9-8329-99c8f0df3982',
//   // )!,
// );
// final val = r.headers['content-disposition'];
// "attachment; filename=buglyqq-upload-symbol-v3.3.5.zip"
