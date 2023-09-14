Pod::Spec.new do |s|
  s.name         = "RecurlySDK"
  s.version      = ENV['LIB_VERSION'] || "2.0.1"
  s.summary      = "Integrate recurrent payments in your iOS app in a matter of minutes."

  s.homepage     = "https://dev.recurly.com/docs/client-libraries"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Recurly, Inc." => "support@recurly.com" }


  s.platform     = :ios, '15.2'
  s.source       = { :git => "https://github.com/recurly/recurly-client-ios.git", :tag => "v#{s.version}" }
  s.source_files = 'RecurlySDK-iOS/**/*.{h,m,swift}'

  s.resources    = 'RecurlySDK-iOS/Resources/**/*.{ttf,xcassets}'

  s.frameworks   = 'UIKit', 'Foundation', 'Security', 'CoreGraphics', 'QuartzCore', 'PassKit', 'AddressBook', 'CoreTelephony'
  s.requires_arc = true

  s.xcconfig     = { "OTHER_LDFLAGS" => "-ObjC" }
end
