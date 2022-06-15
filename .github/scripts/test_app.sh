
#!/bin/bash

set -eo pipefail

xcodebuild  -project RecurlySDK-iOS.xcodeproj \
	    -scheme RecurlySDK-iOS \
            -destination platform=iOS\ Simulator,OS=13.3,name=iPhone\ 11 \
            clean Debug | xcpretty
