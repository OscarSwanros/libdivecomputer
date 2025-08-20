#!/bin/bash

# Build script for libdivecomputer iOS framework
# This script builds the library for iOS devices and simulators

set -e

# Configuration
PROJECT_NAME="libdivecomputer"
BUILD_DIR="build-ios"
FRAMEWORK_NAME="LibDiveComputer"
MIN_IOS_VERSION="13.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building libdivecomputer for iOS...${NC}"

# Clean previous builds
if [ -d "$BUILD_DIR" ]; then
    echo -e "${YELLOW}Cleaning previous build...${NC}"
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"

# Function to build for a specific architecture
build_arch() {
    local ARCH=$1
    local SDK=$2
    local PLATFORM=$3
    local BUILD_PATH="$BUILD_DIR/$PLATFORM-$ARCH"
    
    echo -e "${GREEN}Building for $PLATFORM ($ARCH)...${NC}"
    
    mkdir -p "$BUILD_PATH"
    cd "$BUILD_PATH"
    
    # Configure build
    export CC=$(xcrun -sdk $SDK -find clang)
    export CXX=$(xcrun -sdk $SDK -find clang++)
    export CFLAGS="-arch $ARCH -isysroot $(xcrun -sdk $SDK --show-sdk-path) -m$PLATFORM-version-min=$MIN_IOS_VERSION -D_POSIX_C_SOURCE=200809L -DHAVE_PTHREAD_H=1 -DHAVE_UNISTD_H=1"
    export CXXFLAGS=$CFLAGS
    export LDFLAGS=$CFLAGS
    
    # Run configure if it exists, otherwise use manual compilation
    if [ -f "../../configure" ]; then
        ../../configure \
            --host=$ARCH-apple-darwin \
            --prefix="$PWD/install" \
            --disable-shared \
            --enable-static \
            --disable-examples \
            --disable-doc \
            --without-libusb \
            --without-hidapi
    else
        echo -e "${YELLOW}No configure script found. Using manual compilation...${NC}"
        
        # Manual compilation for each source file
        mkdir -p obj
        
        # Compile all C files in src directory
        for file in ../../src/*.c; do
            if [ -f "$file" ]; then
                filename=$(basename "$file" .c)
                # Skip platform-specific files not needed for iOS
                if [[ "$filename" == *"win32"* ]] || [[ "$filename" == *"libdivecomputer.rc"* ]] || [[ "$filename" == "usbhid" ]] || [[ "$filename" == "usb" ]]; then
                    echo "Skipping $filename.c (not needed for iOS)..."
                    continue
                fi
                echo "Compiling $filename.c..."
                $CC $CFLAGS -I../../include -I../../src -DENABLE_LOGGING=1 -DHAVE_CONFIG_H=1 -c "$file" -o "obj/$filename.o" || {
                    echo "Warning: Failed to compile $filename.c, skipping..."
                    continue
                }
            fi
        done
        
        # Create static library
        ar rcs libdivecomputer.a obj/*.o
        
        # Create install structure
        mkdir -p install/lib install/include
        cp libdivecomputer.a install/lib/
        cp -r ../../include/libdivecomputer install/include/
    fi
    
    cd ../..
}

# Build for iOS devices (arm64)
build_arch "arm64" "iphoneos" "ios"

# Build for iOS Simulator (x86_64 for Intel Macs)
if [ "$(uname -m)" = "x86_64" ]; then
    build_arch "x86_64" "iphonesimulator" "ios-simulator"
fi

# Build for iOS Simulator (arm64 for Apple Silicon Macs)
build_arch "arm64" "iphonesimulator" "ios-simulator"

echo -e "${GREEN}Creating XCFramework...${NC}"

# Create XCFramework
XCFRAMEWORK_PATH="$BUILD_DIR/$FRAMEWORK_NAME.xcframework"
rm -rf "$XCFRAMEWORK_PATH"

# Prepare framework arguments
FRAMEWORK_ARGS=""

# Add device framework
if [ -d "$BUILD_DIR/ios-arm64/install" ]; then
    FRAMEWORK_ARGS="$FRAMEWORK_ARGS -library $BUILD_DIR/ios-arm64/install/lib/libdivecomputer.a"
    FRAMEWORK_ARGS="$FRAMEWORK_ARGS -headers $BUILD_DIR/ios-arm64/install/include"
fi

# Add simulator frameworks
if [ -d "$BUILD_DIR/ios-simulator-x86_64/install" ] && [ -d "$BUILD_DIR/ios-simulator-arm64/install" ]; then
    # Create fat library for simulator
    mkdir -p "$BUILD_DIR/ios-simulator-universal"
    lipo -create \
        "$BUILD_DIR/ios-simulator-x86_64/install/lib/libdivecomputer.a" \
        "$BUILD_DIR/ios-simulator-arm64/install/lib/libdivecomputer.a" \
        -output "$BUILD_DIR/ios-simulator-universal/libdivecomputer.a"
    
    FRAMEWORK_ARGS="$FRAMEWORK_ARGS -library $BUILD_DIR/ios-simulator-universal/libdivecomputer.a"
    FRAMEWORK_ARGS="$FRAMEWORK_ARGS -headers $BUILD_DIR/ios-simulator-arm64/install/include"
elif [ -d "$BUILD_DIR/ios-simulator-arm64/install" ]; then
    FRAMEWORK_ARGS="$FRAMEWORK_ARGS -library $BUILD_DIR/ios-simulator-arm64/install/lib/libdivecomputer.a"
    FRAMEWORK_ARGS="$FRAMEWORK_ARGS -headers $BUILD_DIR/ios-simulator-arm64/install/include"
fi

# Create XCFramework
xcodebuild -create-xcframework $FRAMEWORK_ARGS -output "$XCFRAMEWORK_PATH"

echo -e "${GREEN}Build complete!${NC}"
echo -e "${GREEN}XCFramework created at: $XCFRAMEWORK_PATH${NC}"
echo ""
echo -e "${YELLOW}To use in your iOS project:${NC}"
echo "1. Drag $XCFRAMEWORK_PATH into your Xcode project"
echo "2. Or add as a Swift Package dependency using the Package.swift file"
echo "3. Import the module: import LibDiveComputer"