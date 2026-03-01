#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint document_scanner_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'document_scanner_flutter'
  s.version          = '0.0.1'
  s.summary          = 'A document scanner plugin for flutter'
  s.description      = 'A document scanner plugin for flutter'
  s.homepage         = 'https://github.com/ishaquehassan/document_scanner_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ishaq Hassan' => 'ishaquehassan@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'WeScan', '~> 2.1.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.ios.deployment_target = '12.0'
end
