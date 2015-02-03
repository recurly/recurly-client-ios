
Pod::Spec.new do |s|
  s.name         = "RecurlySDK"
  s.version      = "1.0"
  s.summary      = "Recurly iOS now gives you the speed to securely accept payments as well as the flexibility to build your own checkout UI for subscriptions."
  s.homepage     = "http://recurly.com"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = "Manu Mtz-Almeida"
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/recurly/recurly-client-ios.git", :tag => "v1.0" }

  s.source_files  = 'RecurlySDK-ios/RecurlySDK/**/*.{h,m}'
  s.public_header_files = 'RecurlySDK-ios/RecurlySDK/**/*.h' 

  s.frameworks = 'UIKit', 'Foundation', 'Security', 'CoreGraphics', 'QuartzCore', 'PassKit', 'AddressBook'
  s.requires_arc = true

end
