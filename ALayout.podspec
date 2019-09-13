#
#  Be sure to run `pod spec lint ALayout.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "ALayout"
  spec.version      = "1.5.0"
  spec.summary      = "Layout ported from the Android platform"

  spec.description  = <<-DESC
            Layout ported from the Android platform. Easy to Code For UI.
                   DESC

  spec.homepage     = "https://github.com/splendourbell/ALayout-iOS"
  spec.license      = "MIT"
  spec.author       = { "Splendour Bell" => "zhonghui815@163.com" }

  spec.platform     = :ios, "6.0"
  spec.source       = { :git => "https://github.com/splendourbell/ALayout-iOS.git", :tag => "master" }

  spec.source_files = 'ALayout/**/*.{h,m}'
  spec.public_header_files = 'ALayout/**/*.{h}'

end
