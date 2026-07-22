#!/usr/bin/env bash
set -euo pipefail

# MemPalace Bridge — Free private agent memory
# Install, initialize, start the local MCP server, and configure Hermes.

BOLD='\033[1m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# Hermes stores config under AppData/Local on Windows and ~/.hermes elsewhere.
if [ -n "${LOCALAPPDATA:-}" ]; then
  if command -v cygpath >/dev/null 2>&1; then
    HERMES_HOME="$(cygpath -u "$LOCALAPPDATA")/hermes"
  else
    HERMES_HOME="${LOCALAPPDATA}/hermes"
  fi
elif [ -d "${HOME}/AppData/Local/hermes" ]; then
  HERMES_HOME="${HOME}/AppData/Local/hermes"
else
  HERMES_HOME="${HOME}/.hermes"
fi
HERMES_CFG="${HERMES_HOME}/config.yaml"

echo ""
echo -e "${BOLD}MemPalace Bridge — Free private agent memory${RESET}"
echo ""

# ── Step 1: Install MemPalace ────────────────────────────────────────────
echo -e "${CYAN}Step 1/4: Installing MemPalace...${RESET}"
pip install mempalace
echo -e "${GREEN}✓ MemPalace installed${RESET}"
echo ""

# ── Step 2: Initialize ───────────────────────────────────────────────────
echo -e "${CYAN}Step 2/4: Initializing your memory palace...${RESET}"
export MEMPALACE_WRITER_ROLE="mcp-http-singleton"
mempalace init --yes --no-llm .
echo -e "${GREEN}✓ Palace initialized${RESET}"
echo ""

# ── Step 3: Start MCP server ─────────────────────────────────────────────
echo -e "${CYAN}Step 3/4: Starting the MCP HTTP server...${RESET}"
mempalace-mcp --transport http --host 127.0.0.1 --port 8765 &
MCP_PID=$!
sleep 2

if kill -0 "$MCP_PID" 2>/dev/null; then
  echo -e "${GREEN}✓ MCP server running on http://127.0.0.1:8765${RESET}"
else
  echo -e "${YELLOW}⚠ MCP server may need a moment — check: curl http://127.0.0.1:8765/healthz${RESET}"
fi
echo ""

# ── Step 4: Configure Hermes ─────────────────────────────────────────────
echo -e "${CYAN}Step 4/4: Setting MemPalace as your Hermes memory provider...${RESET}"

if [ -f "$HERMES_CFG" ]; then
  if grep -q "provider: mempalace" "$HERMES_CFG" 2>/dev/null; then
    echo -e "${GREEN}✓ MemPalace is already your Hermes memory provider${RESET}"
  else
    cat >> "$HERMES_CFG" << 'MEMPALACE_BRIDGE_BLOCK'

# ── MemPalace Bridge memory provider ─────────────────────────────────────
memory:
  provider: mempalace
  memory_enabled: true

mcp_servers:
  mempalace:
    url: http://127.0.0.1:8765/mcp
    enabled: true
    connect_timeout: 180
    timeout: 180
MEMPALACE_BRIDGE_BLOCK
    echo -e "${GREEN}✓ MemPalace configured as your Hermes memory provider${RESET}"
    echo "  Restart Hermes for the change to take effect."
  fi
else
  echo -e "${YELLOW}Hermes config not found at ${HERMES_CFG}.${RESET}"
  echo "Add this manually to your Hermes config file:"
  echo ""
  echo "  memory:"
  echo "    provider: mempalace"
  echo "    memory_enabled: true"
  echo "  mcp_servers:"
  echo "    mempalace:"
  echo "      url: http://127.0.0.1:8765/mcp"
  echo "      enabled: true"
fi
echo ""

# ── Next steps ───────────────────────────────────────────────────────────
echo -e "${BOLD}Next steps:${RESET}"
echo ""
echo "  1. Expose the local MCP server through Cloudflare Tunnel:"
echo -e "     ${CYAN}cloudflared tunnel --url http://127.0.0.1:8765${RESET}"
echo ""
echo "  2. Secure the public tunnel with a bearer token before using it in production:"
echo -e "     ${CYAN}python3 -c \"import secrets; print('mcp-' + secrets.token_hex(16))\"${RESET}"
echo "     Save the token. Restart the server with it. See auth-token-config.yaml."
echo ""
echo -e "${GREEN}Done. Your agents have persistent memory through MemPalace Bridge. \$0.${RESET}"
echo ""
