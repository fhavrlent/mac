#!/bin/bash

# macOS Setup Script
# This script installs all your essential apps and tools via Homebrew and Mac App Store

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Welcome message
echo -e "${BLUE}"
echo "=================================="
echo "     macOS Setup Script"
echo "=================================="
echo -e "${NC}"
print_status "This script will install all your essential apps and tools"
print_status "Press Enter to continue or Ctrl+C to cancel"
read -r

# Install Xcode Command Line Tools if not present
if ! xcode-select -p &> /dev/null; then
    print_status "Installing Xcode Command Line Tools..."
    xcode-select --install
    print_warning "Please complete the Xcode Command Line Tools installation and run this script again"
    exit 1
else
    print_success "Xcode Command Line Tools already installed"
fi

# Install Homebrew if not present
if ! command_exists brew; then
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    print_success "Homebrew already installed"
fi

# Update Homebrew
print_status "Updating Homebrew..."
brew update

# Install mas (Mac App Store CLI) first
print_status "Installing mas (Mac App Store CLI)..."
brew install mas

# Homebrew Formulae (CLI tools)
print_status "Installing CLI tools..."
CLI_TOOLS=(
    "atuin"
    "bat"
    "fastfetch"
    "lazydocker"
    "lsd"
    "starship"
    "thefuck"
    "tig"
    "tree"
    "yarn"
)

for tool in "${CLI_TOOLS[@]}"; do
    if brew list --formula | grep -q "^${tool}$"; then
        print_success "$tool already installed"
    else
        print_status "Installing $tool..."
        brew install "$tool"
    fi
done

# Install Nerd Fonts using external script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NERD_FONTS_SCRIPT="$SCRIPT_DIR/nerd_fonts_installer.sh"

if [[ -f "$NERD_FONTS_SCRIPT" ]]; then
    print_status "Found nerd_fonts_installer.sh script"
    
    # Make sure the script is executable
    if [[ ! -x "$NERD_FONTS_SCRIPT" ]]; then
        print_status "Making nerd_fonts_installer.sh executable..."
        chmod +x "$NERD_FONTS_SCRIPT"
    fi
    
    print_status "Running Nerd Fonts installation script..."
    print_warning "This may take a while (installing 60+ fonts)..."
    
    # Run the nerd fonts script and wait for completion
    if "$NERD_FONTS_SCRIPT"; then
        print_success "Nerd Fonts installation completed successfully"
    else
        print_error "Nerd Fonts installation failed"
        print_warning "Continuing with the rest of the setup..."
    fi
else
    print_warning "nerd_fonts_installer.sh not found in the same directory"
    print_status "Installing font-fira-code as fallback..."
    brew install --cask font-fira-code
fi

# Homebrew Casks (GUI Applications)
print_status "Installing GUI applications..."
APPLICATIONS=(
    "1password-cli"
    "1password"
    "adguard"
    "aldente"
    "bartender"
    "betterdisplay"
    "calibre"
    "cyberduck"
    "discord"
    "firefox"
    "ghostty"
    "google-chrome"
    "iina"
    "karabiner-elements"
    "latest"
    "linearmouse"
    "makemkv"
    "mkvtoolnix-app"
    "mkvtoolnix"
    "mockoon"
    "obsidian"
    "orbstack"
    "oversight"
    "pearcleaner"
    "rapidapi"
    "raycast"
    "setapp"
    "viscosity"
    "visual-studio-code"
)

for app in "${APPLICATIONS[@]}"; do
    if brew list --cask | grep -q "^${app}$"; then
        print_success "$app already installed"
    else
        print_status "Installing $app..."
        brew install --cask "$app"
    fi
done

# Mac App Store Applications
print_status "Installing Mac App Store applications..."
print_warning "Please make sure you're signed into the Mac App Store first"
print_status "Press Enter to continue with Mac App Store installations..."
read -r

MAS_APPS=(
    "1569813296"  # 1Password for Safari
    "571213070"   # DaVinci Resolve
    "1509037746"  # Desk Remote Control
    "975937182"   # Fantastical
    "6475835429"  # SimpleLogin for Safari
    "1568262835"  # Super Agent
    "1475387142"  # Tailscale
    "6738342400"  # Tampermonkey
    "425424353"   # The Unarchiver
    "1607635845"  # Velja
    "1497506650"  # Yubico Authenticator
)

for app_id in "${MAS_APPS[@]}"; do
    app_name=$(mas info "$app_id" 2>/dev/null | head -n 1 || echo "Unknown App")
    if mas list | grep -q "$app_id"; then
        print_success "$app_name already installed"
    else
        print_status "Installing $app_name..."
        mas install "$app_id" || print_warning "Failed to install $app_name (ID: $app_id)"
    fi
done

# Cleanup
print_status "Cleaning up..."
brew cleanup

# Final setup suggestions
echo -e "${GREEN}"
echo "=================================="
echo "     Setup Complete!"
echo "=================================="
echo -e "${NC}"

print_status "Additional setup:"
echo "1. Configure Raycast as launcher"
echo "2. Set up Starship"
echo "3. Configure Karabiner-Elements"
echo "4. Set up Bartender"
echo "5. Set up Tailscale"
echo "6. Configure Atuin"

print_status "To add fzf key bindings to your shell, run:"
echo "$(brew --prefix)/opt/fzf/install"

print_status "Your macOS setup is now complete! 🎉"