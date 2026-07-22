#!/usr/bin/env bash
set -euo pipefail

# Darkloom — Free private agent memory
# One script: install, initialize, start, configure Hermes, and guide you through the rest.

BOLD='\033[1m'
CYAN='\033[36m'
GREEN='\033[32m'
RESET='\033[0m'
HERMES_HOME="${HOME}/AppData/Local/hermes"
HERMES_CFG="${HERMES_HOME}/c"+"onfig.y"+"aml"

echo ""
echo -e "${BOLD}Darkloom — Free private agent memory${RESET}"
echo ""

# ── Step 1: Install MemPalace ────────────────────────────────────────────
echo -e "${CYAN}Step 1/4: Installing MemPalace...${RESET}"
pip install mempalace
echo -e "${GREEN}✓ MemPalace installed${RESET}"
echo ""

# ── Step 2: Initialize ───────────────────────────────────────────────────
echo -e "${CYAN}Step 2/4: Initializing your memory palace...${RESET}"
mempalace init .
echo -e "${GREEN}✓ Palace initialized${RESET}"
echo ""

# ── Step 3: Start MCP server ─────────────────────────────────────────────
echo -e "${CYAN}Step 3/4: Starting the MCP HTTP server...${RESET}"
export MEMPALACE_WRITER_ROLE="mcp-http-singleton"
mempalace mcp serve --host 127.0.0.1 --port 8765 &
MCP_PID=$!
sleep 2

if kill -0 $MCP_PID 2>/dev/null; then
  echo -e "${GREEN}✓ MCP server running on http://127.0.0.1:8765${RESET}"
else
  echo "⚠ MCP server may need a moment — check: curl http://127.0.0.1:8765/healthz"
fi
echo ""

# ── Step 4: Configure Hermes ─────────────────────────────────────────────
echo -e "${CYAN}Step 4/4: Setting MemPalace as your Hermes memory provider...${RESET}"

if [ -f "$HERMES_CFG" ]; then
  if grep -q "provider: mempalace" "$HERMES_CFG" 2>/dev/null; then
    echo -e "${GREEN}✓ MemPalace is already your Hermes memory provider${RESET}"
  else
    cat >> "$HERMES_CFG" << 'DARKLOOM_BLOCK'

# ── MemPalace memory provider (added by Darkloom) ───────────────────────
memory:
  provider: mempalace
  memory_enabled: true

mcp_servers:
  mempalace:
    url: http://127.0.0.1:8765/mcp
    enabled: true
    connect_timeout: 180
    timeout: 180
DARKLOOM_BLOCK
    echo -e "${GREEN}✓ MemPalace configured as your Hermes memory provider${RESET}"
    echo "  Restart Hermes for the change to take effect."
  fi
else
  echo "  Hermes config not found at expected path."
  echo "  Add this manually to your Hermes config file:"
  echo ""
  echo "    memory:"
  echo "      provider: mempalace"
  echo "      memory_enabled: true"
  echo "    mcp_servers:"
  echo "      mempalace:"
  echo "        url: http://127.0.0.1:8765/mcp"
  echo "        enabled: true"
fi
echo ""

# ── Next steps ───────────────────────────────────────────────────────────
echo -e "${BOLD}Next steps:${RESET}"
echo ""
echo "  1. Expose to the internet (free):"
echo -e "     ${CYAN}cloudflared tunnel --url http://127.0.0.1:8765${RESET}"
echo ""
echo "  2. Secure with an auth token:"
echo -e "     ${CYAN}python3 -c \"import secrets; print('mcp-' + secrets.token_hex(16))\"${RESET}"
echo "     Save the token. Restart the server with it. See auth-token-config.yaml."
echo ""
echo "  3. Set up the dream cycle (optional, recommended):"
echo "     See dream-cycle-config.yaml. Point it at any model."
echo ""

echo -e "${GREEN}Done. Your agents have persistent memory. Forever. \$0.${RESET}"
echo ""
