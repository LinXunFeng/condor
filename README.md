## 安装

### Homebrew

```shell
brew tap LinXunFeng/tap && brew install condor
```

### Pub Global

```shell
dart pub global activate condor_cli
```

## 使用

### 符号表

<details>

<summary>符号表配置初始化与上传</summary>

#### 初始化

输出配置文件到指定目录

```shell
condor init -o ~/Downloads/condor
```

如有些配置是固定的，可以通过 `-r` 参数指定一个配置文件的路径，这样会将固定的配置写入到输出的配置文件中进行覆盖

```shell
condor init -o ~/Downloads/condor -r ~/Downloads/condor/config2.yaml
```

|参数|别名|描述|
|-|-|-|
|`ref`|`r`|指定固定配置文件的路径|
|`out`|`o`|指定配置文件的输出目录路径|
|`symbolZipPath`|-|符号表压缩包路|
|`bundleId`|-|`app` 的 `bundleId`|
|`version`|-|`app` 的版本|
|`flutterVersion`|-|`Flutter` 版本|
|`buglyAppId`|-|`bugly` 的 `appid`|
|`buglyAppKey`|-|`bugly` 的 `appkey`|
|`buglyJarPath`|-|`buglyqq-upload-symbol.jar` 的路径|


#### 上传符号表

> 针对 `fastlane` 打出来的符号表压缩包

通过指定最后的配置文件的路径来上传符号表

```shell
condor upload -c ~/Downloads/condor/config.yaml
```

</details>

### Flutter

输出当前的 `flutter` 版本

```shell
# 输出
# 3.13.9
condor flutter version print
```

```shell
# 输出 fvm 指定的 flutter 的版本
# 3.7.12
condor flutter version print -f 'fvm spawn 3.7.12'
```

在 `jenkins` 中使用

> 以 `FLUTTER_VERSION` 环境变量来记录当前的 `flutter` 版本供全局使用

```groovy
environment {
  FLUTTER_VERSION = sh(script: "condor flutter version print -f 'fvm spawn ${flutter_version}'", returnStdout: true).trim()
}
```

### 优化 `Flutter` 项目 `ios` 端的编译速度

依赖 [Rugby](https://github.com/swiftyfinch/Rugby) 实现，所以需要先安装 `Rugby`

```shell
curl -Ls https://swiftyfinch.github.io/rugby/install.sh | bash
```

在你的终端配置(如: `~/.zshrc`)中添加如下配置

```shell
export PATH=$PATH:~/.rugby/clt
```

在 `pod install` 完成后执行如下命令进行优化

```shell
condor optimize-build --config path/to/rugby/plans.yml
```

指定 `flutter` 版本

```shell
condor optimize-build --config path/to/rugby/plans.yml --flutter "fvm spawn 3.24.5"
```
