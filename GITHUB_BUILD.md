# Building with GitHub Actions (FREE - No Mac Needed!)

This is the **easiest way** to build your iOS app **without owning a Mac**.

## 🎯 Step-by-Step Guide

### 1. Create a GitHub Account
If you don't have one: https://github.com/signup

### 2. Create a New Repository
1. Go to https://github.com/new
2. Name it: `ios-signer-app`
3. Make it **Public** (required for free Actions)
4. Click "Create repository"

### 3. Upload Your Code

**Option A: Using GitHub Website**
1. Click "uploading an existing file"
2. Drag the entire `SignerApp` folder
3. Click "Commit changes"

**Option B: Using Git (if installed)**
```bash
cd SignerApp
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/ios-signer-app.git
git push -u origin main
```

### 4. Wait for the Build
1. Go to the "Actions" tab in your repository
2. You'll see "Build iOS IPA" running
3. Wait 5-10 minutes for it to complete
4. The build runs on GitHub's free macOS machines!

### 5. Download Your IPA
Once the build is complete:
1. Click on the completed build
2. Scroll down to "Artifacts"
3. Download "SignerApp-IPA"
4. Unzip it - you'll find your IPA file!

### 6. Install on iPhone
1. Install **AltStore** on Windows: https://altstore.io/
2. Connect your iPhone via USB
3. Open AltStore
4. Drag the IPA file into AltStore
5. It will install on your iPhone!

## 🔧 Troubleshooting

### Build Failed?
- Check the "Actions" tab logs
- Most common issue: Missing dependencies
- Solution: Make sure all files are uploaded

### Can't Download Artifacts?
- Make sure the build completed successfully (green checkmark)
- Artifacts expire after 90 days
- Re-run the build if needed

### IPA Won't Install?
- Use AltStore or Sideloadly
- Make sure your iPhone is connected and trusted
- Check that you're signed in with your Apple ID

## ⚡ Re-building

Every time you push changes to GitHub, it automatically builds a new IPA!

```bash
# Make changes to your code
git add .
git commit -m "Updated features"
git push

# GitHub Actions will automatically build a new IPA!
```

## 💰 Cost

**Completely FREE!**
- GitHub Actions gives 2,000 free minutes/month
- Each iOS build takes ~5-10 minutes
- You can build 200-400 times per month for free

## 🚀 Advanced: Automatic Releases

The workflow is configured to automatically create releases:
1. Push to `main` branch
2. GitHub builds the IPA
3. Creates a new release with version number
4. IPA is attached to the release
5. Download anytime from the "Releases" page!

## 📱 Using the App

Once installed on your iPhone:
1. Open "IPA Signer Pro"
2. Select your IPA file
3. Select your certificate (.p12)
4. Select your provisioning profile
5. Tap "Sign IPA"
6. Wait for the signing to complete
7. Install the signed IPA!

## 🎓 Summary

**What You Did:**
- ✅ Created complete iOS sideloading app
- ✅ Built it using GitHub's free Mac machines
- ✅ Got an IPA without owning a Mac
- ✅ Can now sign and install apps on your iPhone

**What You Need:**
- ✅ GitHub account (free)
- ✅ AltStore (free)
- ✅ Your iPhone
- ✅ USB cable

**What You Don't Need:**
- ❌ A Mac computer
- ❌ Paid cloud services
- ❌ Complex setup

## 🔗 Useful Links

- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **AltStore**: https://altstore.io/
- **Sideloadly**: https://sideloadly.io/
- **GitHub Free Tier**: https://github.com/pricing

---

**Congrats!** You just built an iOS app without a Mac! 🎉
