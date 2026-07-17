#!/bin/bash

# ICHITO Release Script
# Usage: ./release.sh <version_tag> "Release notes"
# Example: ./release.sh v1.0.0 "Initial stable release"

VERSION=$1
NOTES=$2

GITHUB_TOKEN="${GITHUB_TOKEN:-}"
CODEBERG_TOKEN="${CODEBERG_TOKEN:-}"

if [ -z "$GITHUB_TOKEN" ] || [ -z "$CODEBERG_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN and CODEBERG_TOKEN must be set as environment variables."
    exit 1
fi

if [ -z "$VERSION" ]; then
    echo "Error: Version tag is required."
    echo "Usage: ./release.sh <version_tag> \"Release notes\""
    exit 1
fi
if [ -z "$NOTES" ]; then
    echo "Error: Release notes are required."
    echo "Usage: ./release.sh <version_tag> \"Release notes\""
    exit 1
fi

echo "Building ICHITO Android ARM64 APK..."
flutter build apk --target-platform android-arm64 --release
if [ $? -ne 0 ]; then
    echo "Build failed. Aborting release."
    exit 1
fi

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "$APK_PATH" ]; then
    echo "Error: APK not found at $APK_PATH"
    exit 1
fi

echo "Creating release $VERSION..."

# Ensure we are on main branch
git checkout main

# Create annotated tag
git tag -a "$VERSION" -m "$NOTES"

# Push to GitHub
echo "Pushing tag to GitHub..."
git push origin "$VERSION"

# Push to Codeberg
echo "Pushing tag to Codeberg..."
git push codeberg "$VERSION"

# Create GitHub Release
echo "Creating GitHub Release and uploading APK asset..."
export GH_TOKEN=$GITHUB_TOKEN
gh release create "$VERSION" "$APK_PATH#ichito-android-arm64-${VERSION}.apk" --title "ICHITO Release $VERSION" --notes "$NOTES"

# Create Codeberg Release
echo "Creating Codeberg Release..."
RESPONSE=$(curl -s -X POST "https://codeberg.org/api/v1/repos/funbinet/ichito/releases" \
  -H "accept: application/json" \
  -H "Authorization: token $CODEBERG_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "tag_name": "'$VERSION'",
    "name": "ICHITO Release '$VERSION'",
    "body": "'"$NOTES"'",
    "draft": false,
    "prerelease": false
  }')

# Extract release ID (hacky bash parsing, works if ID is present)
RELEASE_ID=$(echo $RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ ! -z "$RELEASE_ID" ]; then
    echo "Uploading APK asset to Codeberg Release ID: $RELEASE_ID..."
    curl -s -X POST "https://codeberg.org/api/v1/repos/funbinet/ichito/releases/$RELEASE_ID/assets" \
      -H "accept: application/json" \
      -H "Authorization: token $CODEBERG_TOKEN" \
      -F "attachment=@$APK_PATH;type=application/vnd.android.package-archive" \
      -F "name=ichito-android-arm64-$VERSION.apk" > /dev/null
    echo "Codeberg Asset uploaded."
else
    echo "Failed to extract Codeberg Release ID. Asset upload skipped."
    echo "Codeberg Response: $RESPONSE"
fi

echo "Release $VERSION fully published on GitHub and Codeberg!"
