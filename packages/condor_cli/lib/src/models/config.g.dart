// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
      symbolZipPath: json['symbol_zip_path'] as String?,
      symbols:
          (json['symbols'] as List<dynamic>?)?.map((e) => e as String).toList(),
      bundleId: json['bundle_id'] as String?,
      version: json['version'] as String?,
      platform: json['platform'] as String?,
      flutter: json['flutter'] == null
          ? null
          : Flutter.fromJson(json['flutter'] as Map<String, dynamic>),
      bugly: json['bugly'] == null
          ? null
          : Bugly.fromJson(json['bugly'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
      'symbol_zip_path': instance.symbolZipPath,
      'symbols': instance.symbols,
      'bundle_id': instance.bundleId,
      'version': instance.version,
      'platform': instance.platform,
      'flutter': instance.flutter,
      'bugly': instance.bugly,
    };

Bugly _$BuglyFromJson(Map<String, dynamic> json) => Bugly(
      appId: json['app_id'] as String?,
      appKey: json['app_key'] as String?,
      jarPath: json['jar_path'] as String?,
    );

Map<String, dynamic> _$BuglyToJson(Bugly instance) => <String, dynamic>{
      'app_id': instance.appId,
      'app_key': instance.appKey,
      'jar_path': instance.jarPath,
    };

Flutter _$FlutterFromJson(Map<String, dynamic> json) => Flutter(
      version: json['version'] as String?,
    );

Map<String, dynamic> _$FlutterToJson(Flutter instance) => <String, dynamic>{
      'version': instance.version,
    };
