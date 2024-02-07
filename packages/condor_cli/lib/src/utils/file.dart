import 'dart:io';

import 'package:path/path.dart' as p;

/// 文件管理单例
CondorFile file = CondorFile();

/// 文件管理
class CondorFile {
  /// 获取配置文件
  File getConfigYamlFile({
    required Directory cwd,
  }) {
    return File(p.join(cwd.path, 'config.yaml'));
  }

  /// Condor 的临时目录
  Directory getCondorTempDir() {
    final systemTemp = Directory.systemTemp;
    final tempDirPath = p.join(systemTemp.path, 'condor');
    final tempDir = Directory(tempDirPath);
    if (!tempDir.existsSync()) {
      tempDir.createSync();
    }
    return tempDir;
  }
}
