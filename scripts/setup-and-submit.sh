#!/bin/bash

# 🎲 DiceRollerSimulator - Complete Setup and App Store Submission
# This script will handle signing setup and App Store submission

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

echo -e "${BLUE}🎲 DiceRollerSimulator - Complete Setup and App Store Submission${NC}"
echo -e "${BLUE}============================================================${NC}"

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

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Step 1: Setup Apple ID and get development team
print_status "Step 1: Configuring Apple Developer Account"

print_info "This script will help you set up your Apple Developer account for App Store submission."
print_info "If prompted, please enter your Apple ID credentials."

# Open Xcode to ensure user is signed in
print_status "Opening Xcode to verify Apple ID..."
open -a Xcode
sleep 3

# Try to get available teams by signing with allowProvisioningUpdates
print_status "Attempting to resolve signing automatically..."

# Create a temporary build to trigger signing resolution
xcodebuild -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination generic/platform=iOS \
    -allowProvisioningUpdates \
    -allowProvisioningDeviceRegistration \
    build || {
    
    print_warning "Automatic signing resolution failed. You need to:"
    echo "1. Open Xcode and go to Preferences → Accounts"
    echo "2. Add your Apple ID if not already added"
    echo "3. Make sure you have an active Apple Developer Program membership"
    echo "4. In the project settings, select your team under 'Signing & Capabilities'"
    echo ""
    echo "Would you like to:"
    echo "a) Open Xcode project to configure signing manually"
    echo "b) Continue with simulator build (no App Store upload)"
    echo "c) Exit and try again later"
    
    read -p "Enter your choice (a/b/c): " choice
    
    case $choice in
        a)
            print_info "Opening Xcode project..."
            open "$PROJECT_FILE"
            echo "Please configure signing and run this script again."
            exit 0
            ;;
        b)
            print_info "Building for simulator instead..."
            DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro"
            UPLOAD_TO_APPSTORE=false
            ;;
        c)
            print_info "Exiting. Please set up your Apple Developer account and try again."
            exit 0
            ;;
        *)
            print_error "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

if [ "${UPLOAD_TO_APPSTORE:-true}" = "true" ]; then
    print_success "Apple Developer account configured successfully!"
    DESTINATION="generic/platform=iOS"
fi

# Step 2: Clean and build
print_status "Step 2: Building the app..."

mkdir -p "$PROJECT_DIR/build"

# Clean the project
print_info "Cleaning project..."
xcodebuild -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -configuration Release \
    clean

# Build the project
print_info "Building for device..."
xcodebuild -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination "$DESTINATION" \
    -allowProvisioningUpdates \
    build

print_success "Build completed successfully!"

# Step 3: Create archive (only if building for device)
if [ "${UPLOAD_TO_APPSTORE:-true}" = "true" ]; then
    print_status "Step 3: Creating archive..."
    
    rm -rf "$ARCHIVE_PATH"
    
    xcodebuild -project "$PROJECT_FILE" \
        -scheme "$SCHEME" \
        -configuration Release \
        -destination "$DESTINATION" \
        -archivePath "$ARCHIVE_PATH" \
        -allowProvisioningUpdates \
        archive
    
    print_success "Archive created successfully!"
    print_info "Archive location: $ARCHIVE_PATH"
    
    # Step 4: Export and upload to App Store
    print_status "Step 4: Preparing for App Store submission..."
    
    # Open App Store Connect
    print_info "Opening App Store Connect..."
    open "https://appstoreconnect.apple.com/apps"
    
    # Create export options
    EXPORT_PATH="$PROJECT_DIR/build/export"
    mkdir -p "$EXPORT_PATH"
    
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
    print_info "Exporting and uploading to App Store Connect..."
    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_PATH" \
        -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
        -allowProvisioningUpdates || {
        
        print_warning "Automatic upload failed. Let's try manual upload."
        print_info "Opening Xcode Organizer..."
        open -a Xcode
        sleep 2
        osascript -e 'tell application "Xcode" to activate' || true
        
        print_info "In Xcode:"
        print_info "1. Go to Window → Organizer"
        print_info "2. Select your archive"
        print_info "3. Click 'Distribute App'"
        print_info "4. Choose 'App Store Connect'"
        print_info "5. Follow the prompts to upload"
        
        read -p "Press Enter after uploading to App Store Connect..."
    }
    
    print_success "App uploaded to App Store Connect!"
    
else
    print_success "Simulator build completed successfully!"
fi

# Step 5: Next steps
print_status "Step 5: Next Steps"

if [ "${UPLOAD_TO_APPSTORE:-true}" = "true" ]; then
    echo -e "\n${GREEN}🎉 SUCCESS! Your app is now on App Store Connect!${NC}"
    echo -e "${BLUE}=========================================${NC}"
    
    print_info "In App Store Connect, you now need to:"
    echo "1. Fill in app information (use content from app-store/description.md)"
    echo "2. Add screenshots for required device sizes"
    echo "3. Set up app privacy information"
    echo "4. Submit for review"
    
    echo -e "\n${BLUE}📋 Required Information (Ready to Copy/Paste):${NC}"
    echo "• Bundle ID: $BUNDLE_ID"
    echo "• App Name: $PROJECT_NAME"
    echo "• Version: $VERSION"
    echo "• Build: $BUILD_NUMBER"
    echo "• Description: app-store/description.md"
    echo "• Keywords: dice, roller, simulator, D&D, tabletop, gaming"
    echo "• Category: Games (Primary), Utilities (Secondary)"
    echo "• Price: Free"
    echo "• Contact Email: tiatheone@protonmail.com"
    
    echo -e "\n${YELLOW}📱 Still Need to Create:${NC}"
    echo "• App screenshots (iPhone 6.7\", 6.5\", 5.5\", iPad Pro 12.9\", 11\")"
    echo "• App icon (1024x1024)"
    echo "• Privacy policy webpage"
    
    echo -e "\n${PURPLE}🎯 Typical Timeline:${NC}"
    echo "• Today: Complete app information and screenshots"
    echo "• Tomorrow: Submit for review"
    echo "• 1-7 days: App Store review process"
    echo "• Next week: Your app is live on the App Store! 🎉"
    
else
    echo -e "\n${YELLOW}📱 Simulator Build Complete${NC}"
    echo -e "${BLUE}=========================${NC}"
    
    print_info "Your app builds successfully! To submit to App Store:"
    echo "1. Set up your Apple Developer account"
    echo "2. Configure signing in Xcode"
    echo "3. Run this script again"
fi

# Cleanup
rm -f "$PROJECT_DIR/build/ExportOptions.plist"

print_success "Setup complete!"

echo -e "\n${BLUE}🎲 Your DiceRollerSimulator is ready for the App Store!${NC}"
