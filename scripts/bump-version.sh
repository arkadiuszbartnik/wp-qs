#!/bin/bash

# Get current version from Git
CURRENT=$(git tag --sort=-creatordate | head -n 1 | sed 's/^v//')

# Split into components
IFS='.' read -r MAJOR MINOR PATCH <<< "${CURRENT:-0.0.0}"

# Bump PATCH (you can change logic to MINOR/MAJOR)
PATCH=$((PATCH + 1))
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo "Bumping version to v$NEW_VERSION"

# Make commit (if needed)
echo "$NEW_VERSION" > VERSION
git add VERSION
git commit -m "v$NEW_VERSION"

# Create tag and push
git tag v$NEW_VERSION
git push
git push origin v$NEW_VERSION
# Update the VERSION file