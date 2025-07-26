#!/bin/bash

# 🎲 DiceRollerSimulator - Device Registration Helper
# This script helps register iOS devices for development

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎲 DiceRollerSimulator - Device Registration Helper${NC}"
echo -e "${BLUE}=================================================${NC}"

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

print_status "Checking for connected iOS devices..."

# Check if any iOS devices are connected
CONNECTED_DEVICES=$(system_profiler SPUSBDataType | grep -i "iPhone\|iPad" | wc -l)

if [ "$CONNECTED_DEVICES" -gt 0 ]; then
    print_success "Found $CONNECTED_DEVICES iOS device(s) connected"
    
    # Try to get device information
    print_status "Getting device information..."
    
    # Use instruments to list devices
    xcrun instruments -s devices | grep -E "(iPhone|iPad)" | grep -v "Simulator" | head -5
    
    print_status "Attempting to register device automatically..."
    
    # Try to build a simple project to trigger device registration
    if xcodebuild -project DiceRollerSimulator.xcodeproj \
        -scheme DiceRollerSimulator \
        -destination generic/platform=iOS \
        -allowProvisioningUpdates \
        -quiet \
        build 2>/dev/null; then
        print_success "Device registration successful!"
        print_success "You can now run the automation script"
    else
        print_warning "Automatic registration failed"
        print_warning "Manual steps required:"
        echo "1. Open Xcode"
        echo "2. Go to Window > Devices and Simulators"
        echo "3. Select your device and click 'Use for Development'"
        echo "4. Or go to https://developer.apple.com/account/resources/devices/list"
        echo "5. Add your device UDID manually"
    fi
else
    print_warning "No iOS devices connected"
    echo -e "\n${YELLOW}To register a device:${NC}"
    echo "1. Connect your iPhone/iPad to your Mac with a USB cable"
    echo "2. Trust this computer on your iOS device"
    echo "3. Run this script again"
    echo ""
    echo -e "${YELLOW}Or register manually:${NC}"
    echo "1. Go to https://developer.apple.com/account/resources/devices/list"
    echo "2. Click '+' to add a new device"
    echo "3. Enter device name and UDID"
    echo ""
    echo -e "${YELLOW}To get your device UDID:${NC}"
    echo "1. Connect device to Mac"
    echo "2. Open Finder > [Device Name] > General"
    echo "3. Click on serial number to reveal UDID"
    echo "4. Copy the UDID"
fi

print_status "Alternative: TestFlight Beta Testing"
echo "If you can't register devices, consider using TestFlight:"
echo "1. Build for 'Any iOS Device' (still requires one registered device)"
echo "2. Upload to App Store Connect"
echo "3. Create a TestFlight beta"
echo "4. Add beta testers via email (no device registration needed)"

echo -e "\n${PURPLE}🎲 Device registration check complete!${NC}"
