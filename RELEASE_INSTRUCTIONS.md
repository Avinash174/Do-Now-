# Do Now - Google Play Console Release Instructions

## Quick Start

Follow these steps to prepare your app for Google Play Console submission:

### Step 1: Create Keystore (First Time Only)

Generate your release keystore in the `android/` directory:

```bash
cd android
keytool -genkey -v -keystore do_now_release.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias do_now_key -storepass password -keypass password
cd ..
```

**Important**: 
- Change `password` to a secure password
- Save the keystore file safely
- Never commit keystore to git (already in .gitignore)
- Keep passwords secure

### Step 2: Configure Signing

Create `android/key.properties` by copying the template:

```bash
cp android/key.properties.template android/key.properties
```

Edit `android/key.properties`:

```properties
storePassword=YOUR_SECURE_PASSWORD
keyPassword=YOUR_SECURE_PASSWORD
keyAlias=do_now_key
storeFile=/FULL/PATH/TO/android/do_now_release.keystore
```

**Note**: Use absolute path for `storeFile`

### Step 3: Build Release Bundle

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

**Output location**: `build/app/release/app-release.aab`

### Step 4: Verify Build

```bash
# Check if bundle was created
ls -la build/app/release/app-release.aab

# Check size (should be reasonable)
du -sh build/app/release/app-release.aab
```

### Step 5: Test Before Upload (Optional)

Build APK for testing:

```bash
flutter build apk --release
```

**Output**: `build/app/release/app-release.apk`

### Step 6: Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app (if not already created)
3. Fill in app details:
   - App name: "Do Now"
   - Category: Productivity
   - Description: Task management app with Firebase backend

4. Upload APK or AAB:
   - Go to "Release" → "Production"
   - Upload `app-release.aab` (recommended)
   - Add release notes

5. Complete Store Listing:
   - Add app description
   - Add screenshots (recommended: 5-8)
   - Set content rating
   - Add privacy policy
   - Add support email

6. Review & Release:
   - Review all details
   - Check pricing (Free or Paid)
   - Select countries/regions
   - Submit for review

---

## Current Configuration

### ✅ Completed

- ✅ Package name: `com.avinash.donow`
- ✅ App version: `1.0.0+1`
- ✅ Target SDK: 34
- ✅ Min SDK: Standard Flutter minimum
- ✅ Firebase: Configured
- ✅ App name: "Do Now"
- ✅ App icon: Present
- ✅ App logo: Present (`assets/images/app_logo.png`)
- ✅ Signing configuration: Enabled and ready
- ✅ Permissions: Added (Internet, Network, Notifications)

### ⚠️ Still Required

- ⚠️ Generate keystore (one-time per app)
- ⚠️ Create key.properties file
- ⚠️ Privacy Policy URL
- ⚠️ Support Email
- ⚠️ Screenshots for app store
- ⚠️ Google Play Console account

---

## Troubleshooting

### Build fails with "key.properties not found"
→ This is normal for first build. Either:
- Create `android/key.properties` (signing with your keystore)
- Or run `flutter build apk` (debug mode)

### Build fails with permission errors
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

### Bundle size too large
- Run `flutter build appbundle --split-per-abi`
- This creates smaller bundles for each architecture

### Need to increment version
Edit `pubspec.yaml`:
```yaml
version: 1.0.1+2  # increment both version and build number
```

Then rebuild.

---

## Files Modified for Release

- ✅ `android/app/build.gradle.kts` - Updated with signing config
- ✅ `android/key.properties.template` - Template for signing
- ✅ `android/app/src/main/AndroidManifest.xml` - Added permissions
- ✅ `.gitignore` - Added key.properties and keystore

---

## Security Checklist

- [ ] Keystore created and backed up
- [ ] key.properties not committed to git
- [ ] Passwords stored securely
- [ ] Keystore location secured
- [ ] Build tested before release
- [ ] Privacy policy prepared
- [ ] No debug symbols in release build
- [ ] No sensitive data in logs

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev/deployment/android)
- [App Signing Guide](https://developer.android.com/studio/publish/app-signing)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Firebase Setup](https://firebase.google.com/docs/android/setup)

---

**App Ready for Release**: ✅ Yes
**Package Name**: `com.avinash.donow`
**Version**: `1.0.0+1`
**Next Step**: Generate keystore and follow Step 1-6 above
