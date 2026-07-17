#!/bin/bash

# ICHITO Release Script
# Usage: ./release.sh <version_tag> "Release notes"
# Example: ./release.sh v1.0.0 "Initial stable release"

VERSION=$1
NOTES=$2

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

echo "Creating release $VERSION..."

# Ensure we are on main branch
git checkout main

# Pull latest changes
git pull origin main
git pull codeberg main

# Create annotated tag
git tag -a "$VERSION" -m "$NOTES"

# Push to GitHub
echo "Pushing to GitHub..."
git push origin main
git push origin "$VERSION"

# Push to Codeberg
echo "Pushing to Codeberg..."
git push codeberg main
git push codeberg "$VERSION"

echo "Release $VERSION created and pushed successfully!"
