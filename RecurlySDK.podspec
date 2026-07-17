Pod::Spec.new do |s|
  s.name         = "RecurlySDK"
  s.version      = ENV['LIB_VERSION'] || "3.0.0"
  s.summary      = "Integrate recurrent payments in your iOS app in a matter of minutes."

  s.homepage     = "https://github.com/recurly/recurly-client-ios"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Recurly, Inc." => "support@recurly.com" }


  s.platform     = :ios, '14.0'
  s.swift_versions = ['5.7']
  s.source       = { :git => "https://github.com/recurly/recurly-client-ios.git", :tag => "v#{s.version}" }
  s.source_files = 'RecurlySDK-iOS/**/*.{h,m,swift}'

  s.resources    = 'RecurlySDK-iOS/Resources/**/*.{ttf,xcassets}'
  s.resource_bundles = {
    'RecurlySDK_Privacy' => ['RecurlySDK-iOS/PrivacyInfo.xcprivacy']
  }

  s.frameworks   = 'UIKit', 'Foundation', 'Security', 'CoreGraphics', 'QuartzCore', 'PassKit'
  s.requires_arc = true

  s.xcconfig     = { "OTHER_LDFLAGS" => "-ObjC" }
  s.pod_target_xcconfig = { "SWIFT_STRICT_CONCURRENCY" => "targeted" }
end
