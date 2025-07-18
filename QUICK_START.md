# 🎲 DiceRollerSimulator - Quick Start Guide

## Ready to Submit to App Store? Start Here!

### 📋 Prerequisites (Must Complete First)
1. **Apple Developer Account** ($99/year) - [Sign up here](https://developer.apple.com/programs/)
2. **App Store Connect Access** - Same Apple ID as developer account
3. **Xcode** - Already installed ✅

### 🚀 Quick Setup (5 Steps)

#### Step 1: Run the Setup Script
```bash
./app-store/setup-app-store.sh
```

#### Step 2: Configure Xcode (In the opened Xcode project)
- Set **Team** to your Apple Developer Team
- Verify **Bundle ID**: `com.tiation.DiceRollerSimulator`
- Check **Version**: 1.0, **Build**: 1

#### Step 3: Create App in App Store Connect
- Go to [App Store Connect](https://appstoreconnect.apple.com)
- Create new app with Bundle ID: `com.tiation.DiceRollerSimulator`
- Copy description from `app-store/description.md`

#### Step 4: Upload Build
- Archive in Xcode (Product → Archive)
- Upload to App Store Connect
- Wait for processing (15-30 minutes)

#### Step 5: Submit for Review
- Fill required metadata in App Store Connect
- Add screenshots (required for all device sizes)
- Submit for review

### 📱 Required App Store Assets

#### App Icons (Create these first!)
- 1024x1024 - App Store icon
- 180x180 - iPhone 6 Plus/6s Plus/7 Plus/8 Plus
- 167x167 - iPad Pro
- 152x152 - iPad, iPad mini
- 120x120 - iPhone 6/6s/7/8
- 87x87 - iPhone 6 Plus/6s Plus/7 Plus/8 Plus settings
- 80x80 - iPhone 6/6s/7/8 settings, iPad settings
- 76x76 - iPad
- 58x58 - iPhone 5s/6/6s/7/8 settings
- 40x40 - iPad settings
- 29x29 - iPhone/iPad settings
- 20x20 - iPad notifications

#### Screenshots (Required for submission)
- iPhone 6.7" (iPhone 14 Pro Max)
- iPhone 6.5" (iPhone 11 Pro Max, iPhone XS Max)
- iPhone 5.5" (iPhone 8 Plus)
- iPad Pro 12.9" (3rd generation)
- iPad Pro 11" (2nd generation)

### 🎯 App Store Information

**App Name**: DiceRollerSimulator
**Bundle ID**: com.tiation.DiceRollerSimulator
**Category**: Games (Primary), Utilities (Secondary)
**Content Rating**: 4+
**Price**: Free
**Contact**: tiatheone@protonmail.com

### 📝 Metadata (Copy & Paste Ready)

**App Description**: 
```
Transform your tabletop gaming experience with DiceRollerSimulator, the most advanced dice rolling app on the App Store. Whether you're playing D&D, board games, or need a reliable random number generator, our app delivers stunning 3D visuals and professional-grade functionality.

Key Features:
🎲 Multiple Dice Types: Roll 4, 6, 8, 10, 12, or 20-sided dice
🎯 3D Animation: Realistic physics-based dice rolling
📊 Roll History: Track and analyze your rolls
🎨 Premium Themes: Beautiful dice skins and sound packs
🌙 Dark Mode: Full iOS Dark Mode support
♿ Accessibility: VoiceOver support included
☁️ iCloud Sync: Sync across all devices
🏆 Game Center: Compete with friends
📱 Widget Support: Quick rolls from Home Screen
🎤 Siri Shortcuts: Voice-activated rolling
```

**Keywords**: 
```
dice, roller, simulator, D&D, tabletop, gaming, random, number, generator, RPG, board, games, probability, statistics, 3D, animation
```

### 🔗 Important Links

- **App Store Connect**: https://appstoreconnect.apple.com
- **Developer Portal**: https://developer.apple.com/account
- **Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/

### ⚠️ Common Issues & Solutions

**Build Errors**:
- Check code signing settings in Xcode
- Ensure valid provisioning profile
- Update team and bundle ID

**Archive Fails**:
- Clean build folder (Product → Clean Build Folder)
- Check for any Swift warnings/errors
- Verify all required icons are added

**App Store Connect Issues**:
- Ensure bundle ID matches exactly
- Check all required metadata fields
- Verify privacy policy URL is accessible

### 📞 Support

**Email**: tiatheone@protonmail.com
**Setup Issues**: Check `app-store/APP_STORE_SETUP_GUIDE.md` for detailed guide

### 🎉 Success Timeline

- **Today**: Complete setup and first build
- **Day 1-2**: Upload to App Store Connect
- **Day 2-3**: Submit for review
- **Day 3-10**: App Store review process
- **Day 10+**: App goes live on App Store!

---

**💡 Pro Tip**: Use TestFlight for beta testing before public release. It's free and helps catch issues early!

**🚨 Remember**: The App Store review process typically takes 1-7 days. Plan accordingly!
