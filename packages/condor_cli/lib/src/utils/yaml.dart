import 'dart:io';

import 'package:yaml/yaml.dart';

/// YAML管理单例
CondorYaml yaml = CondorYaml();

/// YAML管理
class CondorYaml {
  /// 加载YAML文件（Map）
  Map<String, dynamic> loadToMap(String path) {
    final jsonStr = File(path).readAsStringSync();
    final map = yamlToDart(loadYaml(jsonStr));
    if (map is Map<String, dynamic>) {
      return map;
    }
    return {};
  }

  /// YamlMap YamlList 对象转为 Map List
  /// https://github.com/dart-lang/yaml/issues/147#issuecomment-1836666943
  /// Recreates all Maps and Lists recursively to ensure normal Dart types
  dynamic yamlToDart(dynamic value) {
    if (value is Map) {
      final entries = <MapEntry<String, dynamic>>[];
      // we cannot directly use `entries` because `YamlMap` will return Nodes
      // instead of values.
      for (final key in value.keys) {
        if (key is String) {
          entries.add(MapEntry(key, yamlToDart(value[key])));
        }
      }
      return Map.fromEntries(entries);
    } else if (value is List) {
      return List<dynamic>.from(value.map(yamlToDart));
    } else {
      return value;
    }
  }
}
