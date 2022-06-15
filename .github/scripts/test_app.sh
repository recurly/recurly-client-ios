
#!/bin/bash

set -eo pipefail

xcodebuild  -project RecurlySDK-iOS.xcodeproj \
	    -scheme RecurlySDK-iOSTests \
	    -sdk iphonesimulator \
            -destination platform=iOS\ Simulator,OS=15.2,name=iPhone\ 15 \
            clean test | xcpretty
