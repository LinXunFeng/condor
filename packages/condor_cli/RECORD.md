<!-- A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`. -->


## 命令

```shell
flutter pub run build_runner build
```

查看所有已安装的可执行文件
```shell
dart pub global list
```

全局激活安装

```shell
dart pub global activate --source path 'xx/xxx/condor/packages/condor_cli'
```

全局卸载

```shell
dart pub global deactivate condor_cli
```

编译成可执行文件

```
dart compile exe bin/condor.dart
```

相关说明: [dart-compile](https://dart.dev/tools/dartw-compile)

打包

```shell
tar -zcf condor.tar.gz condor
```


## Flutter

- [Flutter.dSYM](https://console.cloud.google.com/storage/browser/flutter_infra_release/flutter/)

## 镜像
- [tuna](https://mirrors.tuna.tsinghua.edu.cn/)
- [SJTUG](https://mirrors.sjtug.sjtu.edu.cn)

## 工具
- `JSON` 转模型: [quicktype](https://app.quicktype.io/?l=dart)