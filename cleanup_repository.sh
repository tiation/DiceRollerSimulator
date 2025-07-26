#!/bin/bash

# Repository Cleanup Script for tiation-dice-roller-ios
# This script removes unnecessary files and reorganizes the repository

echo "🧹 Starting repository cleanup..."

# Create backup directory with timestamp
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
echo "📦 Creating backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Function to safely move files to backup
safe_move() {
    if [ -e "$1" ]; then
        echo "  Moving $1 to backup..."
        mv "$1" "$BACKUP_DIR/" 2>/dev/null || echo "  ⚠️  Could not move $1"
    fi
}

# 1. Remove all .DS_Store files
echo -e "\n🗑️  Removing .DS_Store files..."
find . -name ".DS_Store" -type f -delete
echo "  ✅ Removed all .DS_Store files"

# 2. Move backend directory to backup
echo -e "\n📁 Moving backend directory..."
safe_move "backend"

# 3. Move web-related files
echo -e "\n🌐 Moving web-related files..."
safe_move "_config.yml"
safe_move "CNAME"
safe_move "index.md"
safe_move "surge.json"

# 4. Move redundant/old code files
echo -e "\n📄 Moving redundant code files..."
safe_move "ContentView_Complex.swift"
safe_move "ContentView_WithDependencies.swift"
safe_move "test_roll_history.swift"

# 5. Move unused feature files
echo -e "\n🔧 Moving unused feature files..."
safe_move "AnalyticsManager.swift"
safe_move "APIClient.swift"
safe_move "PaymentManager.swift"
safe_move "StoreView.swift"
safe_move "FlexibleView.swift"
safe_move "Tabs.swift"

# 6. Move deployment scripts
echo -e "\n🚀 Moving deployment scripts..."
safe_move "automate-app-store.sh"
safe_move "configure-app-store-connect.sh"
safe_move "create-release-archive.sh"
safe_move "deploy-to-vps.sh"
safe_move "register-device.sh"

# 7. Consolidate documentation
echo -e "\n📚 Organizing documentation..."
mkdir -p "docs/archive"

# Move documentation files to docs/archive
for doc in ARCHIVE_SUCCESS.md EXPORT_SUCCESS_FINAL.md GENERAL_DICE_UPDATE_SUMMARY.md \
           IMMEDIATE_ACTIONS.md SUBMISSION_READY.md VPS_DEPLOYMENT_GUIDE.md \
           REPOSITORY_GRAPH.md REPOSITORY_INDEX.md app-store-checklist.md QUICK_START.md; do
    if [ -f "$doc" ]; then
        echo "  Moving $doc to docs/archive..."
        mv "$doc" "docs/archive/" 2>/dev/null
    fi
done

# 8. Clean up duplicate files
echo -e "\n🔄 Removing duplicates..."
safe_move "export_options.plist"  # Keep ExportOptions.plist

# 9. Move Ruby files
echo -e "\n💎 Moving Ruby files..."
safe_move "Gemfile"

# 10. Consolidate app-store directory
echo -e "\n📱 Moving app-store directory to docs..."
if [ -d "app-store" ]; then
    mv "app-store" "docs/" 2>/dev/null || echo "  ⚠️  Could not move app-store directory"
fi

# 11. Update .gitignore to prevent DS_Store files
echo -e "\n📝 Updating .gitignore..."
if ! grep -q "\.DS_Store" .gitignore; then
    echo -e "\n# macOS\n.DS_Store" >> .gitignore
    echo "  ✅ Added .DS_Store to .gitignore"
fi

# 12. Create a cleanup summary
echo -e "\n📊 Creating cleanup summary..."
cat > "$BACKUP_DIR/cleanup_summary.txt" << EOF
Repository Cleanup Summary
========================
Date: $(date)
Backup Directory: $BACKUP_DIR

Files and directories moved to backup:
- Backend directory (Node.js server)
- Web deployment files (_config.yml, CNAME, etc.)
- Redundant ContentView variants
- Unused feature files (Analytics, API, Payments, etc.)
- Deployment scripts
- Documentation files (moved to docs/archive)
- Duplicate files

To restore any file:
  mv $BACKUP_DIR/[filename] .

To remove backup permanently:
  rm -rf $BACKUP_DIR
EOF

# Final summary
echo -e "\n✨ Cleanup complete!"
echo "📁 Backup created at: $BACKUP_DIR"
echo "📋 Review the cleanup summary: $BACKUP_DIR/cleanup_summary.txt"
echo ""
echo "🎯 Recommended next steps:"
echo "  1. Review the backup directory"
echo "  2. Test the app to ensure everything works"
echo "  3. Commit the cleaned repository"
echo "  4. Delete the backup when confident: rm -rf $BACKUP_DIR"

# Show current directory structure
echo -e "\n📂 New repository structure:"
ls -la | grep -v "backup_" | head -20
