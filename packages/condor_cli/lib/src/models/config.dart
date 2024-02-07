// ignore_for_file: public_member_api_docs, directives_ordering

// To parse this JSON data, do
//
//     final config = configFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'config.g.dart';

// Config configFromJson(String str) => Config.fromJson(json.decode(str));

String configToJson(Config data) => json.encode(data.toJson());

@JsonSerializable()
class Config {
  @JsonKey(name: "symbol_zip_path")
  String? symbolZipPath;
  @JsonKey(name: "symbols")
  List<String>? symbols;
  @JsonKey(name: "bundle_id")
  String? bundleId;
  @JsonKey(name: "version")
  String? version;
  @JsonKey(name: "platform")
  String? platform;
  @JsonKey(name: "flutter")
  Flutter? flutter;
  @JsonKey(name: "bugly")
  Bugly? bugly;

  Config({
    this.symbolZipPath,
    this.symbols,
    this.bundleId,
    this.version,
    this.platform,
    this.flutter,
    this.bugly,
  });

  Config copyWith({
    String? symbolZipPath,
    List<String>? symbols,
    String? bundleId,
    String? version,
    String? platform,
    Flutter? flutter,
    Bugly? bugly,
  }) =>
      Config(
        symbolZipPath: symbolZipPath ?? this.symbolZipPath,
        symbols: symbols ?? this.symbols,
        bundleId: bundleId ?? this.bundleId,
        version: version ?? this.version,
        platform: platform ?? this.platform,
        flutter: flutter ?? this.flutter,
        bugly: bugly ?? this.bugly,
      );

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}

@JsonSerializable()
class Bugly {
  @JsonKey(name: "app_id")
  String? appId;
  @JsonKey(name: "app_key")
  String? appKey;
  @JsonKey(name: "jar_path")
  String? jarPath;

  Bugly({
    this.appId,
    this.appKey,
    this.jarPath,
  });

  Bugly copyWith({
    String? appId,
    String? appKey,
    String? jarPath,
  }) =>
      Bugly(
        appId: appId ?? this.appId,
        appKey: appKey ?? this.appKey,
        jarPath: jarPath ?? this.jarPath,
      );

  factory Bugly.fromJson(Map<String, dynamic> json) => _$BuglyFromJson(json);

  Map<String, dynamic> toJson() => _$BuglyToJson(this);
}

@JsonSerializable()
class Flutter {
  @JsonKey(name: "version")
  String? version;

  Flutter({
    this.version,
  });

  Flutter copyWith({
    String? version,
  }) =>
      Flutter(
        version: version ?? this.version,
      );

  factory Flutter.fromJson(Map<String, dynamic> json) =>
      _$FlutterFromJson(json);

  Map<String, dynamic> toJson() => _$FlutterToJson(this);
}
