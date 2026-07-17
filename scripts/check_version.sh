#!/usr/bin/env bash
#
# Read-only drift check. Verifies /VERSION, the Swift constant, the podspec
# fallback, and the SDK framework's Version.xcconfig all agree. On a
# `release` event, also verifies VERSION matches the git tag.
#
# Usage: scripts/check_version.sh

set -e

cd "$(dirname "$0")/.."

version=$(cat VERSION | tr -d '[:space:]')

swift_version=$(grep -oE 'static let version = "[^"]*"' RecurlySDK-iOS/Helpers/RecurlySDK.swift | sed -E 's/.*"(.*)"/\1/')
podspec_version=$(grep -oE "s\.version[[:space:]]*=[[:space:]]*ENV\['LIB_VERSION'\][[:space:]]*\|\|[[:space:]]*\"[^\"]*\"" RecurlySDK.podspec | sed -E 's/.*"(.*)"/\1/')
xcconfig_version=$(grep -oE '^MARKETING_VERSION = .*' RecurlySDK-iOS/Config/Version.xcconfig | sed -E 's/MARKETING_VERSION = //')

fail=0

check() {
  local name=$1
  local value=$2
  if [ "$value" != "$version" ]; then
    echo "Version mismatch: $name is '$value', VERSION file is '$version'"
    fail=1
  fi
}

check "RecurlySDK.swift" "$swift_version"
check "RecurlySDK.podspec" "$podspec_version"
check "Version.xcconfig" "$xcconfig_version"

if [ "$GITHUB_EVENT_NAME" = "release" ]; then
  if [ -z "$GITHUB_REF_NAME" ]; then
    echo "GITHUB_REF_NAME must be set on the release event. Aborting."
    exit 1
  fi
  tag_version=${GITHUB_REF_NAME#v}
  check "git tag ($GITHUB_REF_NAME)" "$tag_version"
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "Version check passed: $version"
