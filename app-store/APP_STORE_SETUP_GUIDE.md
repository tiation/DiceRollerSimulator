# DiceRollerSimulator - App Store Setup Guide

## Prerequisites Checklist

### 1. Apple Developer Account
- [ ] **Apple Developer Program membership** ($99/year)
- [ ] **App Store Connect access** (same Apple ID as Developer Program)
- [ ] **Team ID** and **Apple ID** ready

### 2. Development Environment
- [x] **Xcode installed** (detected at `/Applications/Xcode.app/Contents/Developer`)
- [ ] **iOS 17+ SDK** (verify in Xcode)
- [ ] **macOS deployment target** if supporting Mac

### 3. Code Signing Setup
- [ ] **Development certificate** installed
- [ ] **Distribution certificate** installed
- [ ] **App Store provisioning profile** created
- [ ] **Bundle ID registered** (`com.tiation.DiceRollerSimulator`)

## Step-by-Step Setup Process

### Phase 1: Apple Developer Account Setup

1. **Sign in to Apple Developer Portal**
   ```bash
   open https://developer.apple.com
   ```
   - Use your Apple ID: `tiatheone@protonmail.com`
   - Ensure your developer program is active

2. **Create App ID**
   - Go to Certificates, Identifiers & Profiles > Identifiers
   - Create new App ID: `com.tiation.DiceRollerSimulator`
   - Enable capabilities: Game Center, iCloud, Push Notifications

3. **Generate Certificates**
   ```bash
   # Create Certificate Signing Request
   open /Applications/Utilities/Keychain\ Access.app
   ```
   - Keychain Access > Certificate Assistant > Request from Certificate Authority
   - Save CSR file for certificate generation

### Phase 2: Xcode Project Configuration

1. **Open Xcode Project**
   ```bash
   open /Users/tiaastor/tiation-github/DiceRollerSimulator/DiceRollerSimulator.xcodeproj
   ```

2. **Configure Project Settings**
   - **Bundle Identifier**: `com.tiation.DiceRollerSimulator`
   - **Version**: `1.0`
   - **Build**: `1`
   - **Deployment Target**: iOS 13.0+
   - **Team**: Select your Apple Developer Team

3. **Enable Capabilities**
   - [ ] Game Center
   - [ ] iCloud (CloudKit)
   - [ ] Push Notifications
   - [ ] Background Modes (if needed)

4. **App Icons & Launch Screen**
   - [ ] App Icon (1024x1024 and all required sizes)
   - [ ] Launch Screen configured
   - [ ] Dark mode support verified

### Phase 3: Code Signing & Provisioning

1. **Create Distribution Certificate**
   ```bash
   # In Xcode: Account Settings > Manage Certificates > +
   # Or use Developer Portal web interface
   ```

2. **Create App Store Provisioning Profile**
   - Developer Portal > Provisioning Profiles > Distribution
   - Type: App Store
   - App ID: `com.tiation.DiceRollerSimulator`
   - Distribution Certificate: Your certificate

3. **Configure Xcode Code Signing**
   - Target > Signing & Capabilities
   - Team: Your Apple Developer Team
   - Provisioning Profile: Automatic or Manual

### Phase 4: App Store Connect Setup

1. **Create App in App Store Connect**
   ```bash
   open https://appstoreconnect.apple.com
   ```
   - My Apps > + > New App
   - **Name**: DiceRollerSimulator
   - **Bundle ID**: `com.tiation.DiceRollerSimulator`
   - **SKU**: `DICE_ROLLER_SIM_001`
   - **Primary Language**: English

2. **Configure App Information**
   - **Category**: Games (Primary), Utilities (Secondary)
   - **Content Rating**: 4+
   - **Price**: Free
   - **Availability**: All Countries

3. **App Description & Keywords**
   - Use content from `/app-store/description.md`
   - **Keywords**: dice, roller, simulator, D&D, tabletop, gaming, random, number, generator, RPG

4. **Screenshots & App Preview**
   - [ ] iPhone 6.7" (required)
   - [ ] iPhone 6.5" (required)
   - [ ] iPhone 5.5" (required)
   - [ ] iPad Pro 12.9" (required)
   - [ ] iPad Pro 11" (required)
   - [ ] App Preview videos (optional but recommended)

### Phase 5: Privacy & Compliance

1. **Privacy Policy**
   - Host privacy policy online
   - Update URL in App Store Connect
   - Current: `https://yourdomain.com/privacy-policy`

2. **App Privacy Labels**
   - Data Not Collected: ✅ (as per description.md)
   - Crash Data: For debugging only, not linked to user

3. **Export Compliance**
   - [ ] App uses encryption: Yes/No
   - [ ] Encryption registration if required

### Phase 6: TestFlight (Optional but Recommended)

1. **Internal Testing**
   - Upload build to TestFlight
   - Add internal testers
   - Test all features thoroughly

2. **External Testing**
   - Create external test group
   - Add beta testers
   - Collect feedback

### Phase 7: Build & Submit

1. **Archive Build**
   ```bash
   # In Xcode:
   # Product > Archive
   # Or use command line:
   xcodebuild -project DiceRollerSimulator.xcodeproj -scheme DiceRollerSimulator -configuration Release -archivePath build/DiceRollerSimulator.xcarchive archive
   ```

2. **Upload to App Store Connect**
   - Xcode Organizer > Distribute App
   - App Store Connect > Upload
   - Choose automatic signing
   - Wait for processing (15-30 minutes)

3. **Submit for Review**
   - App Store Connect > My Apps > DiceRollerSimulator
   - Select build for release
   - Complete all required fields
   - Submit for Review

## Quick Command Reference

### Essential Commands
```bash
# Check code signing identities
security find-identity -v -p codesigning

# List provisioning profiles
ls ~/Library/MobileDevice/Provisioning\ Profiles/

# Build for device
xcodebuild -project DiceRollerSimulator.xcodeproj -scheme DiceRollerSimulator -configuration Release -sdk iphoneos

# Archive
xcodebuild -project DiceRollerSimulator.xcodeproj -scheme DiceRollerSimulator -configuration Release -archivePath build/DiceRollerSimulator.xcarchive archive

# Open project in Xcode
open DiceRollerSimulator.xcodeproj
```

### Useful Links
- [App Store Connect](https://appstoreconnect.apple.com)
- [Apple Developer Portal](https://developer.apple.com)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

## Current Status

### ✅ Completed
- Project structure exists
- App Store metadata prepared
- Privacy policy drafted
- App description written
- Bundle ID configured (`com.tiation.DiceRollerSimulator`)
- Contact email updated (`tiatheone@protonmail.com`)

### ❌ Pending
- Apple Developer Account verification
- Code signing certificates
- Provisioning profiles
- App Store Connect app creation
- App icons and screenshots
- Privacy policy hosting
- Archive and upload

## Next Steps

1. **Immediate**: Set up Apple Developer Account and certificates
2. **Configure Xcode**: Update project settings and code signing
3. **Create assets**: App icons, screenshots, app preview videos
4. **Test build**: Archive and test on device
5. **Submit**: Upload to App Store Connect and submit for review

## Support URLs to Update

Before submission, update these URLs in the metadata:
- `privacy_policy_url`: Host privacy policy and update URL
- `support_url`: Create support page
- `feedback_email`: Update to your preferred support email

## App Store Optimization

### Primary Keywords (High Priority)
- dice roller
- dice simulator
- D&D dice
- tabletop gaming
- random number generator

### Secondary Keywords
- board games
- RPG tools
- gaming utilities
- probability calculator
- dice app

### Localization Strategy
Consider localizing for:
- Spanish (large market)
- French (App Store presence)
- German (gaming market)
- Japanese (mobile gaming)
- Chinese Simplified (huge market)

---

**Note**: This guide assumes you have an active Apple Developer Program membership. The process typically takes 1-2 weeks from setup to App Store approval, depending on review time.
