#!/usr/bin/env zsh
# Standalone installer/loader for zsh-secrets without Oh My Zsh

# Get the directory where this script is located
ZSH_SECRETS_DIR=${0:a:h}

# Source the core functionality
source "$ZSH_SECRETS_DIR/zsh-secrets-core.zsh"

echo "zsh-secrets loaded successfully!"
echo ""
echo "To make this permanent, add one of these lines to your ~/.zshrc:"
echo ""
echo "  # Option 1: Source this installer"
echo "  source $ZSH_SECRETS_DIR/install.zsh"
echo ""
echo "  # Option 2: Source the core directly"
echo "  source $ZSH_SECRETS_DIR/zsh-secrets-core.zsh"
echo ""
echo "Don't forget to set your GPG recipient:"
echo "  export ZSH_SECRETS_RECIPIENT=your-email@example.com"