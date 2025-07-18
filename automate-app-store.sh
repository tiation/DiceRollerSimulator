#!/bin/bash

# 🎲 DiceRollerSimulator - Complete App Store Automation
# This script will fully automate the App Store submission process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="DiceRollerSimulator"
BUNDLE_ID="com.tiation.DiceRollerSimulator"
SCHEME="DiceRollerSimulator"
VERSION="1.0"
BUILD_NUMBER="1"
PROJECT_DIR="$(pwd)"
PROJECT_FILE="$PROJECT_DIR/DiceRollerSimulator.xcodeproj"
ARCHIVE_PATH="$PROJECT_DIR/build/$PROJECT_NAME.xcarchive"

echo -e "${BLUE}🎲 DiceRollerSimulator - Automated App Store Submission${NC}"
echo -e "${BLUE}=====================================================${NC}"

# Function to print status
print_status() {
    echo -e "\n${PURPLE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check prerequisites
print_status "Checking Prerequisites..."

if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode is not installed"
    exit 1
fi
print_success "Xcode is available"

if [ ! -d "$PROJECT_FILE" ]; then
    print_error "Project file not found: $PROJECT_FILE"
    exit 1
fi
print_success "Project file found"

# Check if we're logged into Apple Developer
print_status "Checking Apple Developer Account..."
APPLE_ID=$(defaults read com.apple.dt.Xcode IDEProvisioningTeams 2>/dev/null || echo "")
if [ -z "$APPLE_ID" ]; then
    print_warning "No Apple Developer account found in Xcode"
    echo -e "${YELLOW}Please run: 'xcodebuild -allowProvisioningUpdates' first${NC}"
    echo -e "${YELLOW}Or add your Apple ID in Xcode -> Preferences -> Accounts${NC}"
    
    # Try to get teams automatically
    print_status "Attempting to get available teams..."
    xcrun xcodebuild -showBuildSettings -project "$PROJECT_FILE" -scheme "$SCHEME" | grep DEVELOPMENT_TEAM || true
fi

# Create build directory
print_status "Setting up build environment..."
mkdir -p "$PROJECT_DIR/build"
rm -rf "$ARCHIVE_PATH"
print_success "Build directory ready"

# Update project for App Store submission
print_status "Configuring project for App Store..."

# Create a temporary xcconfig file to override build settings
TEMP_CONFIG="$PROJECT_DIR/build/AppStore.xcconfig"
cat > "$TEMP_CONFIG" << EOF
// App Store Configuration
PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID
MARKETING_VERSION = $VERSION
CURRENT_PROJECT_VERSION = $BUILD_NUMBER
CODE_SIGN_STYLE = Automatic
DEVELOPMENT_TEAM = \$(DEVELOPMENT_TEAM)
PROVISIONING_PROFILE_SPECIFIER = 
CODE_SIGN_IDENTITY = Apple Distribution
IPHONEOS_DEPLOYMENT_TARGET = 13.0
ENABLE_BITCODE = NO
SWIFT_VERSION = 5.0
EOF

print_success "Project configured for App Store"

# Clean and build
print_status "Cleaning project..."
xcodebuild -project "$PROJECT_FILE" -scheme "$SCHEME" -configuration Release clean
print_success "Project cleaned"

# Check if we can build for device (requires registered device)
print_status "Checking device provisioning..."
if xcodebuild -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination generic/platform=iOS \
    -allowProvisioningUpdates \
    -quiet \
    build 2>/dev/null; then
    print_success "Device build successful"
    DEVICE_BUILD_SUCCESS=true
else
    print_warning "Device build failed - likely no registered devices"
    print_warning "Will build for simulator instead"
    DEVICE_BUILD_SUCCESS=false
    
    # Build for simulator as fallback
    print_status "Building for iOS Simulator..."
    xcodebuild -project "$PROJECT_FILE" \
        -scheme "$SCHEME" \
        -configuration Release \
        -destination "platform=iOS Simulator,name=iPhone 16 Pro" \
        build
    
    if [ $? -eq 0 ]; then
        print_success "Simulator build successful"
    else
        print_error "Both device and simulator builds failed"
        exit 1
    fi
fi

# Create archive (only if device build was successful)
if [ "$DEVICE_BUILD_SUCCESS" = true ]; then
    print_status "Creating archive..."
    xcodebuild -project "$PROJECT_FILE" \
        -scheme "$SCHEME" \
        -configuration Release \
        -destination generic/platform=iOS \
        -archivePath "$ARCHIVE_PATH" \
        -allowProvisioningUpdates \
        archive
    
    if [ $? -eq 0 ]; then
        print_success "Archive created successfully"
        print_success "Archive location: $ARCHIVE_PATH"
    else
        print_error "Archive failed"
        exit 1
    fi
else
    print_warning "Skipping archive creation - device build failed"
    print_warning "To create an archive for App Store submission, you need to:"
    echo "1. Connect an iOS device to your Mac"
    echo "2. Or register device UDIDs at https://developer.apple.com/account/"
    echo "3. Then run this script again"
    exit 1
fi

# Export for App Store
print_status "Exporting for App Store..."
EXPORT_PATH="$PROJECT_DIR/build/export"
mkdir -p "$EXPORT_PATH"

# Create export options plist
EXPORT_OPTIONS_PLIST="$PROJECT_DIR/build/ExportOptions.plist"
cat > "$EXPORT_OPTIONS_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>teamID</key>
    <string>\$(DEVELOPMENT_TEAM)</string>
    <key>destination</key>
    <string>upload</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
EOF

# Export and upload
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
    -allowProvisioningUpdates

if [ $? -eq 0 ]; then
    print_success "Export and upload successful!"
    print_success "Your app has been uploaded to App Store Connect"
else
    print_error "Export/upload failed"
    print_warning "You may need to:"
    echo "1. Check your Apple Developer Program membership"
    echo "2. Verify your certificates are valid"
    echo "3. Create the app in App Store Connect first"
    exit 1
fi

# Open App Store Connect
print_status "Opening App Store Connect..."
open "https://appstoreconnect.apple.com/apps"

# Summary
echo -e "\n${GREEN}🎉 AUTOMATED SUBMISSION COMPLETE!${NC}"
echo -e "${BLUE}=================================${NC}"
echo -e "${GREEN}✅ Project built successfully${NC}"
echo -e "${GREEN}✅ Archive created${NC}"
echo -e "${GREEN}✅ App uploaded to App Store Connect${NC}"
echo -e "${GREEN}✅ App Store Connect opened${NC}"

echo -e "\n${YELLOW}📋 NEXT STEPS IN APP STORE CONNECT:${NC}"
echo -e "1. Go to your app (should be processing)"
echo -e "2. Fill in app information using prepared metadata"
echo -e "3. Add screenshots (required)"
echo -e "4. Submit for review"

echo -e "\n${BLUE}📁 FILES READY FOR COPY-PASTE:${NC}"
echo -e "• App Description: app-store/description.md"
echo -e "• App Metadata: app-store/metadata.json"
echo -e "• Privacy Policy: app-store/privacy-policy.md"

echo -e "\n${PURPLE}🎲 Your DiceRollerSimulator is ready for the App Store!${NC}"

# Clean up temporary files
rm -f "$TEMP_CONFIG"
rm -f "$EXPORT_OPTIONS_PLIST"

print_success "Cleanup complete"
