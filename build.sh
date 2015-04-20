#!/usr/bin/env bash

CONFIGURATION=${1-Release}

OUTPUT_FOLDER="output"
XCODE_PROJECT="RecurlySDK.xcodeproj"
XCODE_TARJET="RecurlyLib"


LIB_FOLDER="RecurlyLib"
LIB_NAME="librecurly.a"

FRAMEWORK_NAME="RecurlySDK"


TMP_BUILD_PATH="${OUTPUT_FOLDER}/build"
OUTPUT_IPHONEOS_DIR="${TMP_BUILD_PATH}/iphoneos"
OUTPUT_IPHONEOS_PATH="${OUTPUT_IPHONEOS_DIR}/${LIB_NAME}"

OUTPUT_SIMULATOR_DIR="${TMP_BUILD_PATH}/iphonesimulator"
OUTPUT_SIMULATOR_PATH="${OUTPUT_SIMULATOR_DIR}/${LIB_NAME}"

OUTPUT_UNIVERSAL_DIR="${TMP_BUILD_PATH}/universal"
OUTPUT_UNIVERSAL_PATH="${OUTPUT_UNIVERSAL_DIR}/${LIB_NAME}"


function cleanup() {
    mkdir -p "${OUTPUT_FOLDER}"
    rm -rf "${TMP_BUILD_PATH}"
}

function compileForDevice() {
    echo "Compiling for iphoneos with ${CONFIGURATION} in ${OUTPUT_IPHONEOS_DIR}"
    xcodebuild clean build \
        -configuration "${CONFIGURATION}" \
        -project "${XCODE_PROJECT}" \
        -target "${XCODE_TARJET}" \
        CONFIGURATION_BUILD_DIR="${OUTPUT_IPHONEOS_DIR}" | egrep -A 5 "(error|warning):"
}

function compileForSimulator() {
    echo "Compiling for iphonesimulator with ${CONFIGURATION} in ${OUTPUT_SIMULATOR_DIR}"
    xcodebuild clean build \
        -arch x86_64 \
        -arch i386 \
        -sdk iphonesimulator \
        -configuration "${CONFIGURATION}" \
        -project "${XCODE_PROJECT}" \
        -target "${XCODE_TARJET}" \
        CONFIGURATION_BUILD_DIR="${OUTPUT_SIMULATOR_DIR}" | egrep -A 5 "(error|warning):"
}

function createFatBinary() {
    echo "Generating FAT universal binary"
    mkdir "${OUTPUT_UNIVERSAL_DIR}"
    lipo -create -output "${OUTPUT_UNIVERSAL_PATH}" "${OUTPUT_IPHONEOS_PATH}" "${OUTPUT_SIMULATOR_PATH}"
}

function packBinaryHeadersAndResources() {
    LIB_PATH="${OUTPUT_FOLDER}/${LIB_FOLDER}"
    LIB_BINARY_PATH="${LIB_PATH}/${LIB_NAME}"
    LIB_HEADER_PATH="${LIB_PATH}/include"
    echo "Cleaning ${LIB_PATH}"
    rm -rf "${LIB_PATH}"
    mkdir "${LIB_PATH}"

    cp -r "${OUTPUT_UNIVERSAL_PATH}" "${LIB_BINARY_PATH}"
    cp -r "${OUTPUT_IPHONEOS_DIR}/include" "${LIB_PATH}"
}


function generateFakeFramework() {
    FRAMEWORK_PATH="${OUTPUT_FOLDER}/${FRAMEWORK_NAME}/${FRAMEWORK_NAME}.framework"
    FRAMEWORK_HEADER_PATH="${FRAMEWORK_PATH}/Headers"

    echo "Creating ${FRAMEWORK_PATH}"
    rm -rf "${FRAMEWORK_PATH}"
    mkdir -p "${FRAMEWORK_HEADER_PATH}"

    cp -r "${LIB_BINARY_PATH}" "${FRAMEWORK_PATH}/${FRAMEWORK_NAME}"
    cp -r "${LIB_HEADER_PATH}/". "${FRAMEWORK_HEADER_PATH}"
}

cleanup
compileForDevice
compileForSimulator
createFatBinary
packBinaryHeadersAndResources
generateFakeFramework


rm -rf "build/"

echo "DONE!"