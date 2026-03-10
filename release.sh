#!/bin/bash

# Do Now - Google Play Release Helper Script
# This script helps automate the release process

set -e

echo "🚀 Do Now - Google Play Release Setup"
echo "======================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Error: pubspec.yaml not found. Please run this script from the project root.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Project root detected${NC}"
echo ""

# Function to generate keystore
generate_keystore() {
    echo -e "${YELLOW}🔑 Generating Keystore...${NC}"
    
    if [ -f "android/do_now_release.keystore" ]; then
        echo -e "${RED}❌ Keystore already exists at android/do_now_release.keystore${NC}"
        echo "If you want to regenerate, delete the existing keystore first."
        return
    fi
    
    read -p "Enter keystore password: " -s STORE_PASS
    echo ""
    read -p "Enter key password: " -s KEY_PASS
    echo ""
    read -p "Enter your full name: " FULL_NAME
    read -p "Enter your organizational unit (e.g., Development): " ORG_UNIT
    read -p "Enter your organization (e.g., Company Name): " ORG
    read -p "Enter your city: " CITY
    read -p "Enter your state/province: " STATE
    read -p "Enter your country code (e.g., US): " COUNTRY
    
    cd android
    
    keytool -genkey -v \
        -keystore do_now_release.keystore \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -alias do_now_key \
        -storepass "$STORE_PASS" \
        -keypass "$KEY_PASS" \
        -dname "CN=$FULL_NAME, OU=$ORG_UNIT, O=$ORG, L=$CITY, ST=$STATE, C=$COUNTRY"
    
    cd ..
    
    echo -e "${GREEN}✅ Keystore created successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Copy key.properties.template to key.properties"
    echo "2. Edit key.properties with your passwords and keystore path"
    echo "3. Run ./gradlew build --release"
}

# Function to create key.properties
setup_key_properties() {
    echo -e "${YELLOW}📝 Setting up key.properties...${NC}"
    
    if [ -f "android/key.properties" ]; then
        echo -e "${RED}❌ key.properties already exists${NC}"
        read -p "Do you want to overwrite it? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    # Get keystore path
    read -p "Enter full path to keystore (e.g., /Users/name/android/do_now_release.keystore): " KEYSTORE_PATH
    read -p "Enter keystore password: " -s STORE_PASS
    echo ""
    read -p "Enter key password: " -s KEY_PASS
    echo ""
    
    cat > android/key.properties << EOF
storePassword=$STORE_PASS
keyPassword=$KEY_PASS
keyAlias=do_now_key
storeFile=$KEYSTORE_PATH
EOF
    
    echo -e "${GREEN}✅ key.properties created successfully!${NC}"
}

# Function to build release
build_release() {
    echo -e "${YELLOW}🏗️  Building release bundle...${NC}"
    
    echo "flutter clean..."
    flutter clean
    
    echo "flutter pub get..."
    flutter pub get
    
    echo "Building app bundle..."
    flutter build appbundle --release
    
    echo ""
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
    echo ""
    echo "Output: build/app/release/app-release.aab"
    
    if [ -f "build/app/release/app-release.aab" ]; then
        SIZE=$(du -sh "build/app/release/app-release.aab" | cut -f1)
        echo "Bundle size: $SIZE"
    fi
}

# Function to validate build
validate_build() {
    echo -e "${YELLOW}✔️  Validating build...${NC}"
    echo ""
    
    if [ ! -f "build/app/release/app-release.aab" ]; then
        echo -e "${RED}❌ app-release.aab not found!${NC}"
        return
    fi
    
    echo -e "${GREEN}✅ app-release.aab found${NC}"
    
    # Check size
    SIZE=$(du -sh "build/app/release/app-release.aab" | cut -f1)
    echo "✅ Bundle size: $SIZE"
    
    echo ""
    echo -e "${GREEN}✅ Build validated and ready for upload!${NC}"
    echo ""
    echo "Next step: Upload to Google Play Console"
    echo "File: build/app/release/app-release.aab"
}

# Main menu
while true; do
    echo ""
    echo "Select an option:"
    echo "1. Generate Keystore (required once)"
    echo "2. Setup key.properties (configure signing)"
    echo "3. Build Release Bundle"
    echo "4. Validate Build"
    echo "5. Show Release Documentation"
    echo "6. Exit"
    echo ""
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1)
            generate_keystore
            ;;
        2)
            setup_key_properties
            ;;
        3)
            build_release
            ;;
        4)
            validate_build
            ;;
        5)
            echo ""
            echo "📖 Documentation files:"
            echo "- RELEASE_INSTRUCTIONS.md - Detailed release guide"
            echo "- PLAYSTORE_LISTING_CHECKLIST.md - Store listing requirements"
            echo "- GOOGLE_PLAY_RELEASE_GUIDE.md - Complete checklist"
            echo ""
            read -p "Open which file? (1: Release, 2: Store, 3: Guide): " doc_choice
            case $doc_choice in
                1)
                    cat RELEASE_INSTRUCTIONS.md
                    ;;
                2)
                    cat PLAYSTORE_LISTING_CHECKLIST.md
                    ;;
                3)
                    cat GOOGLE_PLAY_RELEASE_GUIDE.md
                    ;;
            esac
            ;;
        6)
            echo -e "${GREEN}👋 Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            ;;
    esac
done
