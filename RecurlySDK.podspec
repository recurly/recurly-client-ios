
Pod::Spec.new do |s|
  s.name         = "RecurlySDK"
  s.version      = "0.9.0"
  s.summary      = "Integrate recurrent payments in your iOS app in a matter of minutes."

  s.homepage     = "https://recurly.com"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Recurly, Inc." => "support@recurly.com" }


  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/recurly/recurly-client-ios.git", :tag => "v#{s.version}" }
  s.source_files = 'RecurlySDK/*.{h,m}'

  s.frameworks   = 'UIKit', 'Foundation', 'Security', 'CoreGraphics', 'QuartzCore', 'PassKit', 'AddressBook', 'CoreTelephony'
  s.requires_arc = true

  s.xcconfig     = { "OTHER_LDFLAGS" => "-ObjC" }
end
