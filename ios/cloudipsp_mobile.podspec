#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint cloudipsp_mobile.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'cloudipsp_mobile'
  s.version          = '0.0.1'
  s.summary          = 'Cloudipsp SDK for Mobile(Android, iOS)'
  s.description      = <<-DESC
Cloudipsp SDK for Mobile(Android, iOS)
                       DESC
  s.homepage         = 'https://fondy.eu'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Maxim Kozenko' => 'max.dnu@gmail.com' }
  s.source           = { :path => '.' }
  s.static_framework = true
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.frameworks = 'UIKit', 'PassKit'
  s.platform = :ios, '11.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386' }
  s.swift_version = '5.0'
end
