# Google Play Console Release Guide for Do Now

## Pre-Release Checklist

### 1. **App Package & Identity**
- [ ] Change package name from `com.example.do_now` to your own (e.g., `com.yourdomain.donow`)
- [ ] Update app identity in build.gradle and AndroidManifest.xml
- [ ] Ensure unique Bundle ID

### 2. **Version Management**
- [ ] Update version in `pubspec.yaml` (format: X.Y.Z+buildNumber)
- [ ] Current: `1.0.0+1` → Update to `1.0.0+1` for first release
- [ ] Increment buildNumber for each new release

### 3. **App Signing**
- [ ] Generate release keystore (one-time)
- [ ] Configure signing in build.gradle
- [ ] Store keystore safely (NEVER commit to git)
- [ ] Keep key password and keystore password secure

### 4. **App Assets & Metadata**
- [x] App logo present: `assets/images/app_logo.png` ✓
- [x] App name: "Do Now" ✓
- [ ] Screenshots (5-8 for Play Store listing)
- [ ] Feature graphic (1024x500 px)
- [ ] App icon (512x512 px for store)
- [ ] Description & short description
- [ ] Privacy Policy URL
- [ ] Support Email

### 5. **Permissions**
- [x] Internet permission configured
- [x] Firebase permissions included
- [ ] Review all permissions in AndroidManifest.xml
- [ ] Only use necessary permissions

### 6. **Firebase Configuration**
- [x] google-services.json present ✓
- [ ] Firebase project linked
- [ ] Firestore/Realtime Database configured
- [ ] Authentication methods enabled

### 7. **Build Configuration**
- [ ] Target SDK: 34 (current) ✓
- [ ] Min SDK: Check flutter.minSdkVersion
- [ ] MultiDex enabled ✓
- [ ] All dependencies up-to-date

### 8. **Content Rating**
- [ ] Complete Google Play content rating questionnaire

### 9. **Pricing & Distribution**
- [ ] Set app price (Free or Paid)
- [ ] Select target countries
- [ ] Set content restrictions

### 10. **Final Testing**
- [ ] Test on multiple Android versions
- [ ] Test on different screen sizes
- [ ] Test authentication flow
- [ ] Test offline functionality
- [ ] Check for crashes/errors

## Step-by-Step Release Process

### Step 1: Update Version
```bash
# In pubspec.yaml
version: 1.0.0+1  # Change to 1.0.0+1 for first release
```

### Step 2: Generate Keystore (First Time Only)
```bash
keytool -genkey -v -keystore ~/do_now_release.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias do_now_key -storepass password -keypass password
```
⚠️ **IMPORTANT**: Save your keystore file and passwords in a secure location!

### Step 3: Configure Signing
Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=do_now_key
storeFile=/path/to/do_now_release.keystore
```

### Step 4: Update build.gradle
Configure release signing in `android/app/build.gradle.kts`

### Step 5: Build Release APK
```bash
flutter build apk --release
```

Output: `build/app/release/app-release.apk`

### Step 6: Build App Bundle (Recommended for Play Store)
```bash
flutter build appbundle --release
```

Output: `build/app/release/app-release.aab`

### Step 7: Upload to Google Play Console
1. Go to Google Play Console
2. Create new app
3. Fill app details & store listing
4. Upload AAB file
5. Complete content rating questionnaire
6. Set up pricing & distribution
7. Submit for review (3-24 hours typically)

## Important Commands

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build APK (for testing)
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# View build output
ls -la build/app/release/
```

## File Checklist

- [x] `pubspec.yaml` - Version configured
- [x] `android/app/build.gradle.kts` - Signing needed
- [x] `android/app/src/main/AndroidManifest.xml` - Reviewed
- [x] `android/app/google-services.json` - Firebase config
- [x] App icons in `android/app/src/main/res/mipmap-*`
- [x] App logo: `assets/images/app_logo.png`

## Support Resources

- [Flutter Build APK/AAB](https://docs.flutter.dev/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Signing Documentation](https://developer.android.com/studio/publish/app-signing)

---

**Status**: Ready for configuration
**Last Updated**: March 10, 2026
