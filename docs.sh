#!/usr/bin/env sh

appledoc \
--create-html \
--project-name "RecurlySDK for iOS" \
--project-company "Recurly Inc." \
--company-id "com.recurly" \
--output "output/docs" \
--logformat xcode \
--keep-intermediate-files \
--no-repeat-first-par \
--no-warn-invalid-crossref \
--merge-categories \
--exit-threshold 2 \
--create-docset \
--install-docset \
--docset-platform-family iphoneos \
--ignore "*.m" \
--ignore "*.mm" \
--index-desc "README.md" \
"output/RecurlyLib/include"

#--ignore "TinySparkSDK/Vendor" \
#--ignore "TinySparkSDK/Private" \