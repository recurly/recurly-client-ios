Pod::Spec.new do |s|
  s.name         = "RecurlySDK"
  s.version      = ENV['LIB_VERSION'] || "v2.0.0" 
  s.summary      = "Integrate recurrent payments in your iOS app in a matter of minutes."

  s.homepage     = "https://dev.recurly.com/docs/client-libraries"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Recurly, Inc." => "support@recurly.com" }


  s.platform     = :ios, '15.6'
  s.source       = { :git => "https://github.com/recurly/recurly-client-ios.git", :tag => "#{s.version}" }
  s.source_files = 'RecurlySDK/*.{h,m}'

  s.frameworks   = 'UIKit', 'Foundation', 'Security', 'CoreGraphics', 'QuartzCore', 'PassKit', 'AddressBook', 'CoreTelephony'
  s.requires_arc = true

  s.xcconfig     = { "OTHER_LDFLAGS" => "-ObjC" }
end
