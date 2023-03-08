Pod::Spec.new do |s|
  s.name             = 'YesidFaceAuthentication'
  s.version          = '0.1.0'
  s.summary          = 'YesidFaceAuthentication SDK for SwiftUI'
  s.description      = 'YesidFaceAuthentication is a library that provides an easy-to-use interface for integrating facial recognition into your SwiftUI apps. With support for both front-facing and rear-facing cameras, you can quickly and securely authenticate your users with just a few lines of code. Whether you are building a banking app, a health app, or any other app that requires secure authentication, YesidFaceAuthentication has you covered.'

  s.homepage         = 'https://github.com/IDTech-Tanzania/YesidFaceAuthentication'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Emmanuel Mtera' => 'emtera@yesid.io' }
  s.source           = { :git => 'https://github.com/IDTech-Tanzania/YesidFaceAuthentication.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_versions = ['5.0']

  s.source_files = 'YesidFaceAuthentication/Classes/**/*'
end
