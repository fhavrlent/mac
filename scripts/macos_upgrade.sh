#!/bin/bash

echo "🔄 Updating macOS system software..."
sudo softwareupdate --install --all --verbose

echo "🔄 Updating App Store apps..."
if ! command -v mas &> /dev/null; then
  echo "Installing mas (Mac App Store CLI)..."
  brew install mas
fi
mas upgrade

echo "🔄 Updating Homebrew..."
brew update
brew upgrade
brew cleanup

echo "🔄 Updating global npm packages..."
if command -v npm &> /dev/null; then
  npm update -g
else
  echo "⚠️ npm not found. Skipping npm updates."
fi

echo "✅ All updates complete!"

