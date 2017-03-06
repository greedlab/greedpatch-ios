#
# Be sure to run `pod lib lint greedpatch-ios.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "greedpatch-ios"
  s.version          = "0.1.1"
  s.summary          = "iOS SDK for greedpatch"
  s.homepage         = "https://github.com/greedlab/greedpatch-ios"
  s.license          = 'MIT'
  s.author           = { "Bell" => "bell@greedlab.com" }
  s.source           = { :git => "https://github.com/greedlab/greedpatch-ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m}'

  # s.prefix_header_file = 'Pod/Classes/greedpatch-ios.pch'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Foundation'
  s.dependency 'AFNetworking'
  s.frameworks = 'Foundation'
  s.dependency 'ZipArchive'
  s.dependency 'FileMD5Hash'
  s.dependency 'JSPatch'
  s.dependency 'JSPatch/Extensions'
  s.dependency 'JSPatch/JPCFunction'
  s.dependency 'JSPatch/JPBlock'
  s.dependency 'JSPatch/JPCFunctionBinder'
  s.dependency 'JSPatch/Loader'

end
