
#!/bin/bash

set -eo pipefail

xcodebuild  -workspace RecurlySDK-iOS \
	    -scheme ContainerApp \
            -destination platform=iOS\ Simulator,OS=13.3,name=iPhone\ 11 \
            clean test | xcpretty
