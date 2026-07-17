#!/usr/bin/env bash
#
# Release-prep tool. Reads /VERSION and regenerates every derived version
# artifact in the repo. Run by a human or release job before tagging —
# NOT part of PR CI (this script WRITES files; see scripts/check_version.sh
# for the read-only PR check).
#
# Usage: scripts/update_version.sh

set -e

cd "$(dirname "$0")/.."

if [ ! -f VERSION ]; then
  echo "VERSION file not found. Aborting."
  exit 1
fi

version=$(cat VERSION | tr -d '[:space:]')
if [ -z "$version" ]; then
  echo "VERSION file is empty. Aborting."
  exit 1
fi

swift_file="RecurlySDK-iOS/Helpers/RecurlySDK.swift"
podspec_file="RecurlySDK.podspec"
xcconfig_file="RecurlySDK-iOS/Config/Version.xcconfig"

# Swift constant
sed -i '' -E "s/static let version = \"[^\"]*\"/static let version = \"$version\"/" "$swift_file"

# Podspec fallback (LIB_VERSION env var still overrides at deploy time)
sed -i '' -E "s/(s\.version[[:space:]]*=[[:space:]]*ENV\['LIB_VERSION'\] \|\| )\"[^\"]*\"/\1\"$version\"/" "$podspec_file"

# Xcconfig (MARKETING_VERSION / CURRENT_PROJECT_VERSION for the SDK framework target)
cat > "$xcconfig_file" <<EOF
// Generated from /VERSION by scripts/update_version.sh — do not edit directly.

MARKETING_VERSION = $version
CURRENT_PROJECT_VERSION = $version
EOF

echo "Updated version artifacts to $version:"
echo "  $swift_file"
echo "  $podspec_file"
echo "  $xcconfig_file"
