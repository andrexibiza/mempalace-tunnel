# Darkloom — Free private agent memory (Windows / PowerShell)
# One script: install, initialize, start, configure Hermes, and guide you.

$cfgFile = "$env:APPDATA\hermes\c" + "onfig.y" + "aml"

Write-Host ""
Write-Host "Darkloom — Free private agent memory" -ForegroundColor White
Write-Host ""

# ── Step 1: Install MemPalace ────────────────────────────────────────────
Write-Host "Step 1/4: Installing MemPalace..." -ForegroundColor Cyan
pip install mempalace
Write-Host "✓ MemPalace installed" -ForegroundColor Green
Write-Host ""

# ── Step 2: Initialize ───────────────────────────────────────────────────
Write-Host "Step 2/4: Initializing your memory palace..." -ForegroundColor Cyan
mempalace init .
Write-Host "✓ Palace initialized" -ForegroundColor Green
Write-Host ""

# ── Step 3: Start MCP server ─────────────────────────────────────────────
Write-Host "Step 3/4: Starting the MCP HTTP server..." -ForegroundColor Cyan
$env:MEMPALACE_WRITER_ROLE = "mcp-http-singleton"
Start-Process -NoNewWindow -FilePath "pythonw" -ArgumentList "-m","mempalace.mcp_server","--palace","$env:USERPROFILE\.mempalace","--transport","http","--host","127.0.0.1","--port","8765"
Start-Sleep -Seconds 2
Write-Host "✓ MCP server starting on http://127.0.0.1:8765" -ForegroundColor Green
Write-Host ""

# ── Step 4: Configure Hermes ─────────────────────────────────────────────
Write-Host "Step 4/4: Setting MemPalace as your Hermes memory provider..." -ForegroundColor Cyan

if (Test-Path $cfgFile) {
  $existing = Get-Content $cfgFile -Raw
  if ($existing -match "provider: mempalace") {
    Write-Host "✓ MemPalace is already your Hermes memory provider" -ForegroundColor Green
  } else {
    $block = @"

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
"@
    Add-Content -Path $cfgFile -Value $block
    Write-Host "✓ MemPalace configured as your Hermes memory provider" -ForegroundColor Green
    Write-Host "  Restart Hermes for the change to take effect." -ForegroundColor Gray
  }
} else {
  Write-Host "  Hermes config not found at expected path." -ForegroundColor Yellow
  Write-Host "  Add this manually to your Hermes config file:" -ForegroundColor Gray
  Write-Host "    memory:" -ForegroundColor Gray
  Write-Host "      provider: mempalace" -ForegroundColor Gray
  Write-Host "    mcp_servers:" -ForegroundColor Gray
  Write-Host "      mempalace:" -ForegroundColor Gray
  Write-Host "        url: http://127.0.0.1:8765/mcp" -ForegroundColor Gray
}
Write-Host ""

# ── Next steps ───────────────────────────────────────────────────────────
Write-Host "Next steps:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Expose to the internet (free):" -ForegroundColor Gray
Write-Host "     cloudflared tunnel --url http://127.0.0.1:8765" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Secure with an auth token:" -ForegroundColor Gray
Write-Host "     python -c `"import secrets; print('mcp-' + secrets.token_hex(16))`"" -ForegroundColor Cyan
Write-Host "     Save the token. Restart the server with it. See auth-token-config.yaml." -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Set up the dream cycle (optional, recommended):" -ForegroundColor Gray
Write-Host "     See dream-cycle-config.yaml. Point it at any model." -ForegroundColor Gray
Write-Host ""

Write-Host "Done. Your agents have persistent memory. Forever. `$0." -ForegroundColor Green
Write-Host ""
