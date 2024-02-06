// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
      symbolZipPath: json['symbolZipPath'] as String,
      symbols:
          (json['symbols'] as List<dynamic>).map((e) => e as String).toList(),
      version: json['version'] as String,
      platform: json['platform'] as String,
      bugly: Bugly.fromJson(json['bugly'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
      'symbolZipPath': instance.symbolZipPath,
      'symbols': instance.symbols,
      'version': instance.version,
      'platform': instance.platform,
      'bugly': instance.bugly,
    };

Bugly _$BuglyFromJson(Map<String, dynamic> json) => Bugly(
      appId: json['appId'] as String,
      appKey: json['appKey'] as String,
      bundleId: json['bundleId'] as String,
      jarPath: json['jarPath'] as String,
    );

Map<String, dynamic> _$BuglyToJson(Bugly instance) => <String, dynamic>{
      'appId': instance.appId,
      'appKey': instance.appKey,
      'bundleId': instance.bundleId,
      'jarPath': instance.jarPath,
    };
