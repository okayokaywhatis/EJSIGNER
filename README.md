# 🚀 IPA Signer Pro

An advanced iOS sideloading and app signing application built with React Native. Sign and install IPA files directly on your iPhone using your own certificates and provisioning profiles.

## ✨ Features

- 📦 **IPA Signing**: Sign any IPA file with your own certificates
- 🔐 **Certificate Management**: Support for .p12 certificates
- 📜 **Provisioning Profiles**: Automatic profile injection
- ⚡ **Native Performance**: Uses iOS private APIs for maximum compatibility
- 🎨 **Beautiful UI**: Modern, dark-themed interface
- 📊 **Activity Logs**: Real-time signing process monitoring
- 💾 **File Management**: Easy file selection and management

## 🛠️ How It Works

This app uses a combination of:
- **React Native** for the cross-platform UI
- **Native iOS modules** (Objective-C) for signing operations
- **Private iOS APIs** (LSApplicationWorkspace) for installation
- **File system operations** for IPA manipulation

### Signing Process

1. **Extract IPA**: Unzips the IPA file to access the app bundle
2. **Inject Provisioning Profile**: Copies your .mobileprovision into the app
3. **Update Bundle ID**: Modifies Info.plist with correct identifier
4. **Sign Frameworks**: Signs all embedded frameworks and dylibs
5. **Sign Main Bundle**: Applies codesign to the entire app
6. **Repackage**: Zips everything back into a signed IPA
7. **Install** (optional): Uses private APIs to install directly

## 📋 Prerequisites

### Required Files
- **IPA File**: The app you want to sign
- **Certificate (.p12)**: Your signing certificate
- **Provisioning Profile (.mobileprovision)**: Your provisioning profile

### Development Requirements
- macOS with Xcode installed
- Node.js 16+
- CocoaPods
- An Apple Developer account (free or paid)

## 🔧 Building the App

### Step 1: Install Dependencies

```bash
cd SignerApp
npm install
cd ios && pod install && cd ..
```

### Step 2: Configure Bundle Identifier

Edit `ios/SignerApp.xcodeproj` and set your bundle identifier (e.g., `com.yourname.signerapp`)

### Step 3: Build for iOS

```bash
# Using React Native CLI
npx react-native run-ios

# Or open in Xcode
open ios/SignerApp.xcworkspace
```

### Step 4: Create IPA for Sideloading

#### Option A: Using Xcode

1. Open `ios/SignerApp.xcworkspace` in Xcode
2. Select your device/signing team
3. Product → Archive
4. Export IPA (Development or Ad Hoc)

#### Option B: Using Command Line

```bash
# Build archive
xcodebuild -workspace ios/SignerApp.xcworkspace \
  -scheme SignerApp \
  -configuration Release \
  -archivePath build/SignerApp.xcarchive \
  archive

# Export IPA
xcodebuild -exportArchive \
  -archivePath build/SignerApp.xcarchive \
  -exportPath build \
  -exportOptionsPlist exportOptions.plist
```

## 📱 Installing on Your iPhone

Since this app uses private APIs, it cannot be distributed through the App Store. You must sideload it:

### Method 1: AltStore (Recommended)
1. Install AltStore on your PC/Mac
2. Connect your iPhone
3. Drag the IPA file into AltStore
4. It will be signed and installed with your Apple ID

### Method 2: Sideloadly
1. Download Sideloadly
2. Connect your iPhone
3. Drag the IPA and enter your Apple ID
4. Install

### Method 3: Xcode
1. Open the project in Xcode
2. Connect your iPhone
3. Select your device
4. Click Run

## 🎯 Usage Guide

### Signing an IPA

1. **Launch the app** on your iPhone
2. **Tap "Select IPA File"** and choose your IPA
3. **Tap "Select Certificate"** and choose your .p12 file
4. **Tap "Select Provisioning Profile"** and choose your .mobileprovision
5. **Tap "Sign IPA"** to start the process
6. **Wait** for the signing to complete (watch the activity log)
7. **Install** the signed IPA using the installation option

### Getting Your Certificate & Provisioning Profile

#### Free Apple ID Method:
```bash
# Install ios-deploy
npm install -g ios-deploy

# This will generate a certificate using your free Apple ID
# The certificate is valid for 7 days
```

#### Paid Developer Account Method:
1. Go to developer.apple.com
2. Certificates, Identifiers & Profiles
3. Create a new certificate
4. Download as .p12
5. Create/download provisioning profile

### Extracting Certificates from Other Apps

If you have an already-signed IPA:
```bash
# Unzip the IPA
unzip app.ipa

# Find the provisioning profile
cp Payload/*.app/embedded.mobileprovision .

# Extract certificate (requires additional tools)
```

## ⚠️ Important Notes

### Security & Limitations

- **Private APIs**: This app uses iOS private APIs that are not officially supported
- **Sandboxing**: iOS sandbox restrictions may limit some operations
- **7-Day Limit**: Free Apple ID certificates expire after 7 days
- **App Store**: This app cannot be published to the App Store
- **Jailbreak**: No jailbreak required, but jailbroken devices have fewer restrictions

### Legal Considerations

- Only sign apps you own or have permission to modify
- Respect software licenses and terms of service
- Do not use for piracy or illegal distribution
- This is for educational and personal use only

## 🔍 Troubleshooting

### "Signing Failed" Error
- Verify your certificate password is correct
- Ensure the provisioning profile matches the certificate
- Check that the bundle ID is properly configured

### "Installation Failed" Error
- Try installing via AltStore instead of direct installation
- Verify your device is trusted in Settings
- Check that the app is properly signed: `codesign -v app.ipa`

### "No .app Directory Found"
- Your IPA might be corrupted
- Try extracting manually to verify structure
- Ensure it's a valid iOS IPA file

### File Picker Not Working
- Grant file access permissions in Settings
- Enable "Files" app access
- Try restarting the app

## 🛠️ Advanced Features

### Batch Signing
Modify `App.js` to accept multiple IPAs:
```javascript
const [ipaFiles, setIpaFiles] = useState([]);
// Process each IPA in a loop
```

### Auto-Refresh (7-Day)
Set up a background task to re-sign apps before expiration:
```javascript
import BackgroundFetch from 'react-native-background-fetch';
// Implement auto-resign logic
```

### Custom Entitlements
Edit the entitlements in the native module:
```objective-c
NSDictionary *entitlements = @{
    @"application-identifier": bundleId,
    @"get-task-allow": @YES,
    @"com.apple.developer.team-identifier": teamId,
    // Add custom entitlements here
};
```

## 📚 Technical Details

### Architecture

```
SignerApp/
├── App.js                    # React Native UI
├── ios/
│   ├── IPASignerModule.h     # Native module header
│   ├── IPASignerModule.m     # Native signing implementation
│   └── Info.plist            # App configuration
├── package.json              # Dependencies
└── README.md                 # This file
```

### Native Module API

```javascript
// Sign an app
IPASignerModule.signApp(appPath, certPath, password, bundleId)
  .then(result => console.log(result))
  .catch(error => console.error(error));

// Install an app
IPASignerModule.installApp(ipaPath)
  .then(result => console.log(result))
  .catch(error => console.error(error));

// Verify signature
IPASignerModule.verifySignature(appPath)
  .then(result => console.log(result))
  .catch(error => console.error(error));
```

### File Structure of an IPA

```
app.ipa (ZIP file)
└── Payload/
    └── AppName.app/
        ├── Info.plist                      # App metadata
        ├── embedded.mobileprovision        # Provisioning profile
        ├── _CodeSignature/                 # Signature data
        ├── Frameworks/                     # Embedded frameworks
        └── [app binary]                    # Main executable
```

## 🤝 Contributing

This is an educational project. Feel free to:
- Report bugs
- Suggest features
- Submit pull requests
- Share improvements

## 📄 License

MIT License - Use at your own risk

## ⚡ Performance Tips

- Keep IPAs under 500MB for best performance
- Clear logs regularly to save memory
- Use development builds for testing
- Production builds are smaller and faster

## 🔗 Useful Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [React Native Documentation](https://reactnative.dev/docs/getting-started)
- [AltStore](https://altstore.io/)
- [Sideloadly](https://sideloadly.io/)
- [iOS Code Signing](https://developer.apple.com/support/code-signing/)

## 💬 Support

For issues and questions:
- Check the troubleshooting section above
- Review iOS console logs
- Test with a simple IPA first
- Verify certificate validity

---

**⚠️ Disclaimer**: This tool is for educational purposes. Use responsibly and only with apps you have the right to modify. The developers are not responsible for any misuse.

**Built with ❤️ using React Native and Objective-C**
