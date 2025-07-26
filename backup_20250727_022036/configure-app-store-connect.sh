#!/bin/bash

# 🎲 DiceRollerSimulator - Configure App Store Connect Access
# ============================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${CYAN}$1${NC}"
    echo -e "${CYAN}$(echo "$1" | sed 's/./=/g')${NC}"
}

print_status() {
    echo -e "\n${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

# Main script
print_header "🎲 DiceRollerSimulator - Configure App Store Connect Access"

print_status "Checking current configuration..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode is not installed or not in PATH"
    exit 1
fi

print_success "Xcode is available"

# Check current development team
CURRENT_TEAM=$(xcodebuild -showBuildSettings -project DiceRollerSimulator.xcodeproj -scheme DiceRollerSimulator 2>/dev/null | grep "DEVELOPMENT_TEAM" | awk '{print $3}' | head -1)

if [ -n "$CURRENT_TEAM" ]; then
    print_success "Development team configured: $CURRENT_TEAM"
else
    print_warning "No development team configured"
fi

# Check certificates
print_status "Checking code signing certificates..."
CERTIFICATES=$(security find-identity -v -p codesigning 2>/dev/null | grep -c "valid identities found")

if [ "$CERTIFICATES" -gt 0 ]; then
    print_success "Code signing certificates found"
    security find-identity -v -p codesigning 2>/dev/null | grep -E "(Apple Development|Apple Distribution)"
else
    print_warning "No code signing certificates found"
fi

# Check if we have distribution certificates
DIST_CERT=$(security find-identity -v -p codesigning 2>/dev/null | grep -c "Apple Distribution")
if [ "$DIST_CERT" -eq 0 ]; then
    print_warning "No Apple Distribution certificate found (required for App Store)"
fi

print_status "Checking App Store Connect access..."

# Try to check available teams
print_info "Attempting to list available teams..."
TEAMS_OUTPUT=$(xcodebuild -showBuildSettings -project DiceRollerSimulator.xcodeproj -scheme DiceRollerSimulator 2>/dev/null | grep "DEVELOPMENT_TEAM" | head -1)

if [ -n "$TEAMS_OUTPUT" ]; then
    print_success "Team configuration found"
else
    print_warning "Unable to determine team configuration"
fi

# Instructions for manual configuration
print_header "📋 CONFIGURATION INSTRUCTIONS"

echo -e "\n${YELLOW}To resolve App Store Connect access issues:${NC}"
echo -e "\n${BLUE}1. Add your Apple ID to Xcode:${NC}"
echo -e "   • Open Xcode"
echo -e "   • Go to Xcode → Settings → Accounts"
echo -e "   • Click '+' and add your Apple ID"
echo -e "   • Make sure it shows your development team"

echo -e "\n${BLUE}2. Create required certificates:${NC}"
echo -e "   • In Xcode Accounts, select your Apple ID"
echo -e "   • Click 'Manage Certificates...'"
echo -e "   • Click '+' to create missing certificates:"
echo -e "     - Apple Development (for testing)"
echo -e "     - Apple Distribution (for App Store)"

echo -e "\n${BLUE}3. Verify App Store Connect access:${NC}"
echo -e "   • Visit https://appstoreconnect.apple.com"
echo -e "   • Make sure you can log in with your Apple ID"
echo -e "   • Check that you have the proper role (Admin/Developer)"

echo -e "\n${BLUE}4. Alternative: Use API Key (Recommended for CI/CD):${NC}"
echo -e "   • Go to App Store Connect → Users and Access → Integrations"
echo -e "   • Create an API Key with 'Developer' role"
echo -e "   • Download the .p8 file"
echo -e "   • Use it in the export command:"
echo -e "     xcodebuild -exportArchive \\"
echo -e "       -authenticationKeyPath /path/to/AuthKey.p8 \\"
echo -e "       -authenticationKeyID YOUR_KEY_ID \\"
echo -e "       -authenticationKeyIssuerID YOUR_ISSUER_ID"

# Check for common issues
print_header "🔍 DIAGNOSTICS"

# Check if Apple ID is stored in keychain
if security find-internet-password -s "idmsa.apple.com" &>/dev/null; then
    print_success "Apple ID credentials found in keychain"
else
    print_warning "No Apple ID credentials found in keychain"
fi

# Check provisioning profiles
PROFILES_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"
if [ -d "$PROFILES_DIR" ]; then
    PROFILE_COUNT=$(find "$PROFILES_DIR" -name "*.mobileprovision" | wc -l)
    if [ "$PROFILE_COUNT" -gt 0 ]; then
        print_success "Found $PROFILE_COUNT provisioning profile(s)"
    else
        print_warning "No provisioning profiles found"
    fi
else
    print_warning "Provisioning profiles directory not found"
fi

# Suggest next steps
print_header "🚀 NEXT STEPS"

echo -e "\n${GREEN}After configuring your Apple ID and certificates:${NC}"
echo -e "1. Run: ${CYAN}./automate-app-store.sh${NC}"
echo -e "2. Or test with: ${CYAN}xcodebuild -exportArchive -allowProvisioningUpdates${NC}"

echo -e "\n${YELLOW}If you continue to have issues:${NC}"
echo -e "1. Check your Apple Developer Program membership status"
echo -e "2. Verify your role in App Store Connect"
echo -e "3. Try signing in to App Store Connect manually first"
echo -e "4. Consider using an API Key for automation"

print_success "Configuration check complete"
