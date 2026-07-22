#!/usr/bin/env bash
set -euo pipefail

# mempalace-tunnel — Linux/macOS setup
# One-command bootstrap for MemPalace + Cloudflare tunnel

echo "==> Installing MemPalace..."
pip install mempalace

echo "==> Initializing MemPalace in current directory..."
mempalace init .

echo "==> Starting MemPalace MCP HTTP server on port 8765..."
mempalace mcp serve --host 127.0.0.1 --port 8765 &

echo "==> Starting Cloudflare tunnel (requires cloudflared on PATH)..."
echo "    Run this in a separate terminal:"
echo "    cloudflared tunnel --url http://127.0.0.1:8765"
echo ""
echo "Done. Your memory is now tunneled to the cloud."
echo ""
echo "Next: set up the dream cycle — edit dream-cycle-config.yaml"
echo "      and add it to your Hermes cron config. Use any model."
