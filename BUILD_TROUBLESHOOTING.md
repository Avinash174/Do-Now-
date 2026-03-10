# 🔧 Flutter Build Troubleshooting Guide

## Issue: Gradle & Build Cache Corruption

### Symptoms
```
Daemon compilation failed: null
Could not close incremental caches
CMake C++ compiler detection failed
```

### Solution (Applied)
```bash
# Complete cache reset
flutter clean
rm -rf build android/.gradle android/app/build
flutter pub get

# Then rebuild
flutter build apk --release
# or
flutter build appbundle --release
```

---

## Common Flutter Build Issues & Fixes

### 1. **Kotlin Compilation Cache Corruption**
**Error**: `Could not close incremental caches`

**Fix**:
```bash
flutter clean
rm -rf android/.gradle
flutter pub get
flutter build apk
```

---

### 2. **NDK/CMake Issues**
**Error**: `CXX compiler identification failed` or `CMake Error`

**Causes**:
- Old NDK version
- Incompatible CMake version
- Corrupted NDK files

**Fixes**:
```bash
# Check NDK version
ls ~/Library/Android/sdk/ndk/

# Update NDK (if using old version)
# Use Android Studio SDK Manager
# Or download from: https://developer.android.com/ndk/downloads

# Force rebuild
flutter clean
flutter pub get
flutter build apk --release
```

---

### 3. **Gradle Daemon Issues**
**Error**: `Daemon failed to connect` or `Daemon compilation failed`

**Fix**:
```bash
# Stop all gradle daemons
./android/gradlew --stop

# Then clean and rebuild
flutter clean
flutter pub get
flutter build apk
```

---

### 4. **Memory/Heap Issues**
**Error**: `OutOfMemoryError` or build hangs

**Fix - Increase Gradle Memory**:

Create or edit `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m
org.gradle.parallel=true
org.gradle.workers.max=4
```

---

### 5. **Plugin Compatibility Issues**
**Error**: Plugin compilation fails

**Fix**:
```bash
flutter pub upgrade
flutter clean
flutter pub get
flutter build apk
```

---

## Release Build Command

### Best Practice (for Google Play):
```bash
# 1. Clean everything
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Output: build/app/release/app-release.aab
```

### Alternative - Build APK:
```bash
flutter build apk --release

# Output: build/app/release/app-release.apk
```

### Split APKs by Architecture:
```bash
flutter build apk --release --split-per-abi

# Output: 
# - app-armeabi-v7a-release.apk
# - app-arm64-v8a-release.apk
# - app-x86_64-release.apk
```

---

## Pre-Build Checklist

```bash
# 1. Verify Flutter setup
flutter doctor

# 2. Check SDK tools
flutter doctor --android-licenses

# 3. Test build (debug)
flutter build apk

# 4. If successful, build release
flutter build appbundle --release
```

---

## Build Verification

```bash
# Check if build was successful
ls -lh build/app/release/

# Verify APK/AAB exists
file build/app/release/app-release.aab
# or
file build/app/release/app-release.apk

# Check file size (should be reasonable)
du -sh build/app/release/app-release.aab
```

---

## Gradle Properties for Optimization

**Add to `android/gradle.properties`**:

```properties
# Memory settings
org.gradle.jvmargs=-Xmx4096m

# Parallel builds
org.gradle.parallel=true
org.gradle.workers.max=4

# Daemon settings
org.gradle.daemon=true
org.gradle.daemon.idletimeout=10800000

# SDK settings
android.useAndroidX=true
android.enableJetifier=true

# Build settings
android.enableOnDemandModules=false
```

---

## Emergency Reset

If all else fails:
```bash
# Nuclear option - reset everything
flutter clean
rm -rf ~/Library/Caches/flutter/*
rm -rf ~/.gradle
rm -rf android/.gradle
rm -rf android/app/build
rm -rf build

# Reinstall dependencies
flutter pub get
flutter pub upgrade

# Try again
flutter build appbundle --release
```

---

## Performance Tips

1. **Disable MultiDex if possible** (in build.gradle)
2. **Use split APKs** for smaller file sizes
3. **Enable parallel gradle builds** (gradle.properties)
4. **Increase JVM memory** if build is slow
5. **Use release build** for final APK (smaller & optimized)

---

## Useful Commands

```bash
# Check build dependencies
flutter pub deps

# Analyze code for issues
flutter analyze

# Format code
flutter format lib/

# Test build (debug)
flutter build apk

# Verbose output for debugging
flutter build apk -v

# Stop gradle daemon
./android/gradlew --stop

# View gradle version
./android/gradlew --version
```

---

## Next Steps

1. ✅ Cache cleared (completed)
2. ⏳ APK build in progress
3. ✓ Once successful, run: `flutter build appbundle --release`
4. ✓ Upload to Google Play Console

---

## Support Resources

- [Flutter Build Documentation](https://docs.flutter.dev/deployment/android)
- [Gradle Documentation](https://docs.gradle.org)
- [Android NDK Setup](https://developer.android.com/ndk)
- [CMake for Android](https://developer.android.com/studio/projects/install-ndk#cmake)

---

**Last Updated**: March 10, 2026
**App Status**: Ready for rebuild after cache clear
