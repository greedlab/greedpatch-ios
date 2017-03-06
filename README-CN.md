# greedpatch-ios

[![Version](https://img.shields.io/cocoapods/v/greedpatch-ios.svg?style=flat)](http://cocoapods.org/pods/greedpatch-ios)
[![License](https://img.shields.io/cocoapods/l/greedpatch-ios.svg?style=flat)](http://cocoapods.org/pods/greedpatch-ios)
[![Platform](https://img.shields.io/cocoapods/p/greedpatch-ios.svg?style=flat)](http://cocoapods.org/pods/greedpatch-ios)

[greedpatch](https://github.com/greedlab/greedpatch) 的 iOS SDK

[English](README.md) | 中文

## 安装

```ruby
pod "greedpatch-ios"
```

## 使用

### 写补丁文件

在工程中使用 [JSPatch](https://github.com/bang590/JSPatch) 写补丁 js 文件.

### 配置 greedpatch

工程在加入类似如下的代码：

```
[[GRPPatchManager sharedInstance] setProjectId:@"57d61489f0068561dce9baee"];
[[GRPPatchManager sharedInstance] setToken:@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE0NzM2NDg2MzA0ODgsImlkIjoiNTdkM2JmMmY5MDE1ZWU0N2ZjYzNjYWJhIiwic2NvcGUiOiJwYXRjaDpjaGVjayJ9.YPedieEibUgLecWDmuIVIdkY_Ra-4Qa2HeIQpE7Z_k8"];
[[GRPPatchManager sharedInstance] setCompressPassword:@"compress_password"];
```

#### ProjectId

[greedpatch](http://patch.greedlab.com) > `Create project` > `Project Detail`. 这样可以看到 `Project ID`

#### Token

访问 [Generate new token](http://patch.greedlab.com/settings/my/tokens/new) 生成 Token

#### compressPassword

加解密补丁的密码

### 测试补丁

```
[[GRPPatchManager sharedInstance] testPatch];
```

### 打包补丁

```
[[GRPPatchManager sharedInstance] compressPatch];
```

从 Xcode 终端可以看到`补丁路径` 和 `Hash`

### 上传补丁

[greedpatch](http://patch.greedlab.com/) > 先对应的工程 > `Create patch` > 填写好各种信息并上传补丁, 点击 `Upload` > `Create`

### 打补丁

```
[[GRPPatchManager sharedInstance] patch];
```

如果本地有适合于当前版本的补丁，就使补丁生效

### 检查是否需要打补丁

```
[[GRPPatchManager sharedInstance] requestPatch];
```

向服务器请求是否需要打补丁

## 例子

[Example](https://github.com/greedlab/greedpatch-ios/tree/master/Example)

## Thanks

[JSPatch](https://github.com/bang590/JSPatch)

## License

greedpatch-ios is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
