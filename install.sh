#!/usr/bin/env bash
set -e

echo "🚀 Installing Claude Code Configuration for Laravel..."

if [ ! -f "artisan" ]; then
    echo "❌ Error: Please run this script from the root of your Laravel project."
    exit 1
fi

REPO_URL="https://github.com/AratKruglik/claude-laravel.git"
TMP_DIR=$(mktemp -d)

echo "📦 Cloning configuration repository..."
git clone --quiet "$REPO_URL" "$TMP_DIR"

echo "📂 Copying files..."
if [ -d "$TMP_DIR/.claude" ]; then
    cp -r "$TMP_DIR/.claude" ./
fi

if [ -f "$TMP_DIR/CLAUDE.md" ]; then
    cp "$TMP_DIR/CLAUDE.md" ./
fi

if [ -f "$TMP_DIR/.mcp.json" ]; then
    if [ ! -f ".mcp.json" ]; then
        cp "$TMP_DIR/.mcp.json" ./
    else
        echo "⚠️ .mcp.json already exists, skipping to prevent overwrite."
    fi
fi

rm -rf "$TMP_DIR"

echo "✅ Installation complete!"
echo "Next steps:"
echo "1. Review CLAUDE.md and adjust Docker commands if needed."
echo "2. Run inside Claude Code: /plugin install superpowers@superpowers-marketplace"
echo "3. Install additional skills: npx skills add <owner/repo>"
