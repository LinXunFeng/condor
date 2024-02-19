## 安装

### Homebrew

```shell
brew tap LinXunFeng/tap && brew install condor
```

### Pub Global

```shell
dart pub global activate condor
```

## 使用

### 初始化

输出配置文件到指定目录

```shell
condor init -o ~/Downloads/condor
```

如有些配置是固定的，可以通过 `-r` 参数指定一个配置文件的路径，这样会将固定的配置写入到输出的配置文件中

```shell
condor init -o ~/Downloads/condor -r ~/Downloads/condor/config2.yaml
```

### 上传符号表

> 针对 `fastlane` 打出来的符号表压缩包

通过指定最后的配置文件的路径来上传符号表

```shell
condor upload -c ~/Downloads/condor/config.yaml
```
