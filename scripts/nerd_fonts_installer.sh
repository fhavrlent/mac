#!/bin/bash

# Nerd Fonts Installation Script
# This script dynamically discovers and installs all available Nerd Fonts via Homebrew

set -e  # Exit on any error

echo "🔤 Installing All Nerd Fonts via Homebrew..."
echo "=================================================="

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Counter for tracking progress
current=0
installed_count=0
skipped_count=0
failed_count=0

if ! command -v brew &> /dev/null; then
    echo -e "${RED}Error: Homebrew is not installed.${NC}"
    echo "Please install Homebrew first: https://brew.sh"
    exit 1
fi

echo "🔍 Discovering available nerd fonts..."
# Get all available nerd fonts dynamically
available_fonts=$(brew search '/font-.*-nerd-font/' | awk '{ print $1 }' || echo "")
total_fonts=$(echo "$available_fonts" | wc -l | tr -d ' ')

echo "Found $total_fonts nerd fonts available in Homebrew"
echo ""

echo "🔍 Checking current nerd font installations..."
# Get all installed nerd fonts in one command
installed_fonts=$(brew list 2>/dev/null | grep 'font-.*-nerd-font' || echo "")
already_installed_count=$(echo "$installed_fonts" | grep -c "nerd-font" || echo "0")

echo "Found $already_installed_count nerd fonts already installed"
echo ""

# Function to check if font is already installed
is_font_installed() {
    local font_name=$1
    # Check if font exists in our installed fonts list
    echo "$installed_fonts" | grep -q "^$font_name$"
}

# Function to install a font with progress tracking
install_font() {
    local font_name=$1
    current=$((current + 1))
    
    echo -e "${YELLOW}[$current/$total_fonts]${NC} Checking $font_name..."
    
    if is_font_installed "$font_name"; then
        echo -e "${GREEN}⏭${NC} $font_name is already installed, skipping..."
        skipped_count=$((skipped_count + 1))
    else
        echo -e "${YELLOW}  ↳${NC} Installing $font_name..."
        if brew install "$font_name" 2>/dev/null; then
            echo -e "${GREEN}  ✓${NC} Successfully installed $font_name"
            installed_count=$((installed_count + 1))
        else
            echo -e "${RED}  ✗${NC} Failed to install $font_name"
            failed_count=$((failed_count + 1))
        fi
    fi
    echo ""
}

# Install all available nerd fonts
echo "Starting font installation..."
echo ""

# Loop through all available fonts and install them
while IFS= read -r font_name; do
    if [[ -n "$font_name" ]]; then
        install_font "$font_name"
    fi
done <<< "$available_fonts"

echo ""
echo "=================================================="
echo -e "${GREEN}🎉 Nerd Fonts installation completed!${NC}"
echo ""
echo "📊 Installation Summary:"
echo -e "  ${GREEN}✓ Newly installed:${NC} $installed_count fonts"
echo -e "  ${YELLOW}⏭ Already installed:${NC} $skipped_count fonts"
echo -e "  ${RED}✗ Failed:${NC} $failed_count fonts"
echo -e "  📋 Total processed: $total_fonts fonts"
echo ""
echo "📝 Notes:"
echo "• Script dynamically discovers all available nerd fonts from Homebrew"
echo "• Fonts are installed system-wide and available in all applications"
echo "• You may need to restart applications to see new fonts"
echo ""
echo "🔍 To verify installation, you can run:"
echo "   brew list | grep nerd-font"