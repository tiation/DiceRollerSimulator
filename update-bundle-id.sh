#!/bin/bash

# Update Bundle ID in Xcode project
PROJECT_FILE="/Users/tiaastor/tiation-github/DiceRollerSimulator/DiceRollerSimulator.xcodeproj/project.pbxproj"
OLD_BUNDLE_ID="com.example.DiceRollerSimulator"
NEW_BUNDLE_ID="com.tiation.DiceRollerSimulator"

echo "🔧 Updating Bundle ID in Xcode project..."
echo "From: $OLD_BUNDLE_ID"
echo "To: $NEW_BUNDLE_ID"

# Create backup
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"

# Replace bundle ID
sed -i '' "s/$OLD_BUNDLE_ID/$NEW_BUNDLE_ID/g" "$PROJECT_FILE"

echo "✅ Bundle ID updated successfully!"
echo "💾 Backup created at: $PROJECT_FILE.backup"
