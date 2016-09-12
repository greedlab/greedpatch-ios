# greedpatch-ios

[![Version](https://img.shields.io/cocoapods/v/greedpatch-ios.svg?style=flat)](http://cocoapods.org/pods/greedpatch-ios)
[![License](https://img.shields.io/cocoapods/l/greedpatch-ios.svg?style=flat)](http://cocoapods.org/pods/greedpatch-ios)
[![Platform](https://img.shields.io/cocoapods/p/greedpatch-ios.svg?style=flat)](http://cocoapods.org/pods/greedpatch-ios)

iOS SDK for [greedpatch](https://github.com/greedlab/greedpatch)


## Installation

greedpatch-ios is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "greedpatch-ios"
```

## Usage

### Write patch files

Write js files with [JSPatch](https://github.com/bang590/JSPatch) in your project.

### Config greedpatch

config greedpatch like

```
[[GRPPatchManager sharedInstance] setProjectId:@"57d61489f0068561dce9baee"];
[[GRPPatchManager sharedInstance] setToken:@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE0NzM2NDg2MzA0ODgsImlkIjoiNTdkM2JmMmY5MDE1ZWU0N2ZjYzNjYWJhIiwic2NvcGUiOiJwYXRjaDpjaGVjayJ9.YPedieEibUgLecWDmuIVIdkY_Ra-4Qa2HeIQpE7Z_k8"];
[[GRPPatchManager sharedInstance] setCompressPassword:@"compress_password"];
```

#### ProjectId

[greedpatch](http://patch.greedlab.com) > `Create project` > `Project Detail`. And then you can see `Project ID`

#### Token

visit [Generate new token](http://patch.greedlab.com/settings/my/tokens/new) to generate it.

#### compressPassword

Used to encrypt you patch file.

### Test patch

```
[[GRPPatchManager sharedInstance] testPatch];
```

test js files in your project

### Compress patch

```
[[GRPPatchManager sharedInstance] compressPatch];
```

Compress js files in your project to a zip file, and generate the hash code for the zip file. You can see them in Xcode's console.

### upload patch

[greedpatch](http://patch.greedlab.com/) > select the project > click `Create patch` > upload zip file rom the last step, click Upload > select the `project version` , input the hash from the last step  > Create

### Patch

```
[[GRPPatchManager sharedInstance] patch];
```

If there are patch available for current project version,the patch will come into effect

### Check need patch

```
[[GRPPatchManager sharedInstance] requestPatch];
```

request remote server whether there a new patch for current project version.

## Demo

[Example](https://github.com/greedlab/greedpatch-ios/tree/master/Example)

## Thanks

[JSPatch](https://github.com/bang590/JSPatch)

## License

greedpatch-ios is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
