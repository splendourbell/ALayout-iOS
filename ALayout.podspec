#
#  Be sure to run `pod spec lint ALayout.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "ALayout"
  spec.version      = "1.3.0"
  spec.summary      = "Layout ported from the Android platform"

  spec.description  = <<-DESC
            Layout ported from the Android platform. Easy to Code For UI.
                   DESC

  spec.homepage     = "https://github.com/splendourbell/ALayout-iOS"
  spec.license      = "MIT"
  spec.author       = { "Splendour Bell" => "zhonghui815@163.com" }

  spec.platform     = :ios, "6.0"
  spec.source       = { :git => "https://github.com/splendourbell/ALayout-iOS.git", :tag => "master" }

  spec.subspec 'Action' do |ss|
      ss.source_files = 'ALayout/ALayout/Action/*.{h,m}'
      ss.public_header_files = 'ALayout/ALayout/Action/*.{h}'
  end

  spec.subspec 'AttributeReader' do |ss|
      ss.source_files = 'ALayout/ALayout/AttributeReader/*.{h,m}'
      ss.public_header_files = 'ALayout/ALayout/AttributeReader/*.{h}'
  end

  spec.subspec 'Drawables' do |ss|
      ss.source_files = 'ALayout/ALayout/Drawables/*.{h,m}'
      ss.public_header_files = 'ALayout/ALayout/Drawables/*.{h}'
  end

  spec.subspec 'Extension' do |ss|
    ss.subspec 'AViewNode' do |sss|
        sss.source_files = 'ALayout/ALayout/Extension/AViewNode/*.{h,m}'
        sss.public_header_files = 'ALayout/ALayout/Extension/AViewNode/*.{h}'
    end
  end

  spec.subspec 'Extension' do |ss|
  ss.subspec 'DataBinder' do |sss|
      sss.source_files = 'ALayout/ALayout/Extension/DataBinder/*.{h,m}'
      sss.public_header_files = 'ALayout/ALayout/Extension/DataBinder/*.{h}'
      end
  end

  spec.subspec 'Extension' do |ss|
  ss.subspec 'ScriptDataBinder' do |sss|
      sss.source_files = 'ALayout/ALayout/Extension/ScriptDataBinder/*.{h,m}'
      sss.public_header_files = 'ALayout/ALayout/Extension/ScriptDataBinder/*.{h}'
      end
  end

  spec.subspec 'ViewGroups' do |ss|
      ss.source_files = 'ALayout/ALayout/ViewGroups/*.{h,m}'
      ss.public_header_files = 'ALayout/ALayout/ViewGroups/*.{h}'
  end

  spec.subspec 'ViewParse' do |ss|
      ss.source_files = 'ALayout/ALayout/ViewParse/*.{h,m}'
      ss.public_header_files = 'ALayout/ALayout/ViewParse/*.{h}'
  end

  spec.subspec 'Views' do |ss|
      ss.source_files = 'ALayout/ALayout/Views/*.{h,m}'
      ss.public_header_files = 'ALayout/ALayout/Views/*.{h}'
  end

end
