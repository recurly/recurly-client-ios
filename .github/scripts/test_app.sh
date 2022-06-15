
#!/bin/bash

set -eo pipefail

xcodebuild  -project RecurlySDK-iOS.xcodeproj \
	    -scheme ContainerApp \
            -destination platform=iOS\ Simulator,OS=13.3,name=iPhone\ 11 \
            clean test | xcpretty
