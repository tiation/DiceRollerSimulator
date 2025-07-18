#!/bin/bash

# DiceRollerSimulator App Store Setup Script
# This script helps automate the App Store setup process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="DiceRollerSimulator"
BUNDLE_ID="com.tiation.DiceRollerSimulator"
SCHEME="DiceRollerSimulator"
PROJECT_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
PROJECT_FILE="$PROJECT_DIR/DiceRollerSimulator.xcodeproj"

echo -e "${BLUE}🎲 DiceRollerSimulator App Store Setup${NC}"
echo -e "${BLUE}======================================${NC}"

# Check prerequisites
echo -e "\n${YELLOW}📋 Checking Prerequisites...${NC}"

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode is not installed or not in PATH${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Xcode is installed${NC}"

# Check if project exists
if [ ! -f "$PROJECT_FILE" ]; then
    echo -e "${RED}❌ Project file not found: $PROJECT_FILE${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Project file found${NC}"

# Check code signing identities
echo -e "\n${YELLOW}🔐 Checking Code Signing...${NC}"
SIGNING_IDENTITIES=$(security find-identity -v -p codesigning | grep "Developer ID\|iPhone Distribution\|Apple Distribution" | wc -l)
if [ "$SIGNING_IDENTITIES" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No code signing identities found${NC}"
    echo -e "${YELLOW}   You'll need to set up certificates in Xcode${NC}"
else
    echo -e "${GREEN}✅ Code signing identities found: $SIGNING_IDENTITIES${NC}"
fi

# Function to open URLs
open_url() {
    local url="$1"
    local description="$2"
    echo -e "\n${BLUE}🌐 Opening: $description${NC}"
    open "$url"
    read -p "Press Enter to continue after completing the task..."
}

# Function to check if user wants to continue
ask_continue() {
    local message="$1"
    echo -e "\n${YELLOW}$message${NC}"
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Setup cancelled by user${NC}"
        exit 1
    fi
}

# Main setup process
echo -e "\n${BLUE}🚀 Starting App Store Setup Process${NC}"

# Step 1: Apple Developer Account
ask_continue "Step 1: Set up Apple Developer Account and certificates"
open_url "https://developer.apple.com/account" "Apple Developer Portal"

# Step 2: App Store Connect
ask_continue "Step 2: Create app in App Store Connect"
open_url "https://appstoreconnect.apple.com" "App Store Connect"

# Step 3: Open Xcode project
ask_continue "Step 3: Configure Xcode project settings"
echo -e "${BLUE}🔧 Opening Xcode project...${NC}"
open "$PROJECT_FILE"

# Step 4: Build and test
ask_continue "Step 4: Build and test the app"

echo -e "\n${YELLOW}🔨 Building project...${NC}"
xcodebuild -project "$PROJECT_FILE" -scheme "$SCHEME" -configuration Release -destination generic/platform=iOS build

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build successful${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    echo -e "${YELLOW}Please fix build errors before continuing${NC}"
    exit 1
fi

# Step 5: Archive
ask_continue "Step 5: Create archive for App Store submission"

echo -e "\n${YELLOW}📦 Creating archive...${NC}"
ARCHIVE_PATH="$PROJECT_DIR/build/$PROJECT_NAME.xcarchive"
mkdir -p "$PROJECT_DIR/build"

xcodebuild -project "$PROJECT_FILE" -scheme "$SCHEME" -configuration Release -archivePath "$ARCHIVE_PATH" archive

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Archive created successfully${NC}"
    echo -e "${BLUE}📁 Archive location: $ARCHIVE_PATH${NC}"
    
    # Open Xcode Organizer
    echo -e "\n${BLUE}🏗️  Opening Xcode Organizer for upload...${NC}"
    open -a Xcode
    echo -e "${YELLOW}In Xcode, go to Window > Organizer to upload your archive${NC}"
else
    echo -e "${RED}❌ Archive failed${NC}"
    exit 1
fi

# Step 6: Final checklist
echo -e "\n${BLUE}📋 Final Checklist${NC}"
echo -e "${BLUE}=================${NC}"
echo -e "${YELLOW}Before submitting to App Store, ensure:${NC}"
echo -e "📱 App icons are added (1024x1024 and all sizes)"
echo -e "📸 Screenshots are prepared for all device sizes"
echo -e "📝 Privacy policy is hosted online"
echo -e "🔗 Support URL is created"
echo -e "📧 Contact email is verified: tiatheone@protonmail.com"
echo -e "🎯 All required metadata is filled in App Store Connect"
echo -e "🧪 App has been tested on physical device"
echo -e "📋 App Store Review Guidelines compliance verified"

# Step 7: Additional resources
echo -e "\n${BLUE}📚 Additional Resources${NC}"
echo -e "${BLUE}======================${NC}"
echo -e "App Store Connect: https://appstoreconnect.apple.com"
echo -e "Developer Portal: https://developer.apple.com"
echo -e "Review Guidelines: https://developer.apple.com/app-store/review/guidelines/"
echo -e "Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/"
echo -e "TestFlight: https://developer.apple.com/testflight/"

echo -e "\n${GREEN}🎉 Setup process completed!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Upload archive to App Store Connect"
echo -e "2. Fill in all required metadata"
echo -e "3. Submit for review"
echo -e "4. Monitor review status"

echo -e "\n${YELLOW}💡 Tip: The review process typically takes 1-7 days${NC}"
echo -e "${YELLOW}💡 Tip: Consider using TestFlight for beta testing first${NC}"
