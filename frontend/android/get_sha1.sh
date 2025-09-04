#!/bin/bash

echo "Getting SHA-1 fingerprint for debug keystore..."

# For debug keystore (default location)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

echo ""
echo "Getting SHA-1 fingerprint for release keystore..."

# For release keystore (if it exists)
if [ -f "app/my-key.jks" ]; then
    echo "Release keystore found. Please enter the keystore password:"
    keytool -list -v -keystore app/my-key.jks -alias my-key-alias
else
    echo "Release keystore not found at app/my-key.jks"
fi

echo ""
echo "Instructions:"
echo "1. Copy the SHA-1 fingerprint(s) above"
echo "2. Go to Firebase Console -> Project Settings -> Your Apps -> Android App"
echo "3. Add the SHA-1 fingerprint(s) to your Android app configuration"
echo "4. Download the updated google-services.json file"
echo "5. Replace the current google-services.json with the new one"
