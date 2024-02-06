// ignore_for_file: public_member_api_docs

import 'package:json_annotation/json_annotation.dart';

part 'config_model.g.dart';

@JsonSerializable()
class Config {
  String symbolZipPath;
  List<String> symbols;
  String version;
  String platform;
  Bugly bugly;

  Config({
    required this.symbolZipPath,
    required this.symbols,
    required this.version,
    required this.platform,
    required this.bugly,
  });

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}

@JsonSerializable()
class Bugly {
  String appId;
  String appKey;
  String bundleId;
  String jarPath;

  Bugly({
    required this.appId,
    required this.appKey,
    required this.bundleId,
    required this.jarPath,
  });

  factory Bugly.fromJson(Map<String, dynamic> json) => _$BuglyFromJson(json);
  Map<String, dynamic> toJson() => _$BuglyToJson(this);
}
