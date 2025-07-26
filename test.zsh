#!/usr/bin/env zsh
# Test script for zsh-secrets

echo "Testing zsh-secrets functionality..."
echo ""

# Test standalone loading
echo "1. Testing standalone loading..."
TEST_DIR=${0:a:h}
source "$TEST_DIR/zsh-secrets-core.zsh"

# Check if function exists
if type secrets >/dev/null 2>&1; then
    echo "   ✓ secrets function loaded"
else
    echo "   ✗ secrets function NOT loaded"
    exit 1
fi

# Test help
echo ""
echo "2. Testing help/usage..."
# The function should fail when called without arguments
if ! secrets 2>&1 | grep -q "Subcommand must be specified"; then
    echo "   ✗ Usage message not shown"
else
    echo "   ✓ Shows usage when no args provided"
fi

echo ""
echo "3. Testing with Oh My Zsh plugin structure..."
# Simulate Oh My Zsh plugin loading
unfunction secrets 2>/dev/null
source "$TEST_DIR/zsh-secrets.plugin.zsh"

if type secrets >/dev/null 2>&1; then
    echo "   ✓ secrets function loaded via plugin"
else
    echo "   ✗ secrets function NOT loaded via plugin"
fi

echo ""
echo "All tests completed!"
echo ""
echo "To test encryption/decryption, ensure you have:"
echo "  export ZSH_SECRETS_RECIPIENT='your-email@example.com'"
echo "Then try:"
echo "  echo 'export TEST_SECRET=42' > test_secret"
echo "  secrets encrypt test_secret"
echo "  secrets source test_secret"
echo "  echo \$TEST_SECRET"
