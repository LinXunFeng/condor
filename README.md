## ☕ 请我喝一杯咖啡

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/T6T4JKVRP) [![wechat](https://img.shields.io/static/v1?label=WeChat&message=微信收款码&color=brightgreen&style=for-the-badge&logo=WeChat)](https://cdn.jsdelivr.net/gh/FullStackAction/PicBed@resource20220417121922/image/202303181116760.jpeg)

微信技术交流群请看: [【微信群说明】](https://mp.weixin.qq.com/s/JBbMstn0qW6M71hh-BRKzw)

## 安装

### Homebrew

```shell
brew install LinXunFeng/tap/condor
````

<!--

首次安装

```shell
brew tap LinXunFeng/tap && brew install condor
```

更新
```shell
brew update && brew reinstall condor
```

### Pub Global

```shell
dart pub global activate condor_cli
```
-->

## 使用

### Copilot - 解除限制

> 文章：[AI - RooCode 解限使用 Copilot Claude 3.7](https://mp.weixin.qq.com/s/MPgDkJ37s9X7DzAvS4azwQ)

在 `Cline` 和 `RooCode` 中使用 `VS Code LM API` + `copilot - claude-3.7.sonnet` 时，会出现如下错误

```
Request Failed: 400 {"error":{"message":"Model is not supported for this request.","param":"model","code":"model_not_supported","type":"invalid_request_error"}}

Retry attempt 1
Retrying in 5 seconds...
```

限制的情况，此时可以通过 `condor` 来解除限制

```shell
condor copilot freedom
```

杀掉并重启 `VS Code` 即可


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

> 文章：[Flutter - iOS编译加速](https://mp.weixin.qq.com/s/iyvoAMCvC8WKN-zWsQcU_w)

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
condor optimize-build \
  --config path/to/rugby/plans.yml \
  --flutter "fvm spawn 3.24.5"
```

指定编译模式

通过 `--mode` 指定，或者设置环境变量 `export CONDOR_BUILD_MODE=release`

```shell
condor optimize-build \
  --config path/to/rugby/plans.yml \
  --mode release
```

### 使用 `Xcode 15` 的工具链优化 `Xcode 16` 的编译

> 文章：[Flutter - Xcode16 还原编译速度](https://mp.weixin.qq.com/s/sVouMFVe-eXoCFEofriasw)

请先安装 `Xcode 16` 以下的版本，如: `Xcode 15.4.0`，建议使用 [XcodesApp](https://github.com/XcodesOrg/XcodesApp) 进行安装

安装完成后，把对应的 `Xcode` 名字记下，如 `/Applications/Xcode-15.4.0.app`，则取 `Xcode-15.4.0`，给下面的命令使用。

#### 拷贝 `xctoolchain`

```shell
condor optimize-build xctoolchain-copy --xcode Xcode-15.4.0
```

#### 重定向 `cc`

这一步会对 `flutter_tools` 源码进行修改，使其具备重定向 `cc` 的能力而已，在有配置 `CONDOR_TOOLCHAINS` 环境变量时才会生效，否则则使用默认的 `cc`。

```shell
# 使用默认 flutter，则不需要传 flutter 参数
condor optimize-build redirect-cc

# 如果你想指定 fvm 下的指定 Flutter 版本
condor optimize-build redirect-cc --flutter fvm spawn 3.24.5
```

设置环境变量 `CONDOR_TOOLCHAINS`，值为上述的 `Xcode` 名。

```shell
export CONDOR_TOOLCHAINS=Xcode-15.4.0
```
