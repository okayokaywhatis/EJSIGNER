#!/bin/bash

# IPA Signer Pro - Build Script
# This script helps you build and export the app as an IPA

echo "🚀 IPA Signer Pro - Build Script"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: This script must be run on macOS${NC}"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: Xcode is not installed${NC}"
    echo "Please install Xcode from the App Store"
    exit 1
fi

# Check if in correct directory
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: Please run this script from the SignerApp directory${NC}"
    exit 1
fi

echo "Step 1: Installing dependencies..."
npm install || { echo -e "${RED}Failed to install npm packages${NC}"; exit 1; }

echo ""
echo "Step 2: Installing CocoaPods..."
cd ios
pod install || { echo -e "${RED}Failed to install pods${NC}"; exit 1; }
cd ..

echo ""
echo "Step 3: Building archive..."
xcodebuild -workspace ios/SignerApp.xcworkspace \
    -scheme SignerApp \
    -configuration Release \
    -archivePath build/SignerApp.xcarchive \
    clean archive || { echo -e "${RED}Failed to build archive${NC}"; exit 1; }

echo ""
echo "Step 4: Creating export options..."
cat > exportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF

echo ""
echo "Step 5: Exporting IPA..."
xcodebuild -exportArchive \
    -archivePath build/SignerApp.xcarchive \
    -exportPath build \
    -exportOptionsPlist exportOptions.plist || { echo -e "${RED}Failed to export IPA${NC}"; exit 1; }

echo ""
echo -e "${GREEN}✅ Build Complete!${NC}"
echo ""
echo "Your IPA is located at: build/SignerApp.ipa"
echo ""
echo "Next steps:"
echo "1. Install via AltStore:"
echo "   - Open AltStore on your Mac"
echo "   - Connect your iPhone"
echo "   - Drag build/SignerApp.ipa into AltStore"
echo ""
echo "2. Or install via Sideloadly:"
echo "   - Open Sideloadly"
echo "   - Select build/SignerApp.ipa"
echo "   - Enter your Apple ID"
echo "   - Click Start"
echo ""
echo -e "${YELLOW}Note: You'll need to sideload this app since it uses private APIs${NC}"
