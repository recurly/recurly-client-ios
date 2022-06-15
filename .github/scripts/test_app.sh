
#!/bin/bash

set -eo pipefail

xcodebuild  -project RecurlySDK-iOS.xcodeproj \
	    -scheme RecurlySDK-iOS \
            -destination 'platform=iOS\ Simulator,OS=15.2,name=iPhone 13' \
	    -only-testing RecurlySDK-iOSTests
