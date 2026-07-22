# MemPalace Bridge - Free private agent memory (Windows / PowerShell)
# Install, initialize, start the local MCP server, and configure Hermes.

$cfgFile = Join-Path $env:LOCALAPPDATA "hermes\config.yaml"

Write-Host ""
Write-Host "MemPalace Bridge - Free private agent memory" -ForegroundColor White
Write-Host ""

# Step 1: Install MemPalace
Write-Host "Step 1/4: Installing MemPalace..." -ForegroundColor Cyan
pip install mempalace
Write-Host "[OK] MemPalace installed" -ForegroundColor Green
Write-Host ""

# Step 2: Initialize
Write-Host "Step 2/4: Initializing your memory palace..." -ForegroundColor Cyan
$env:MEMPALACE_WRITER_ROLE = "mcp-http-singleton"
mempalace init --yes --no-llm .
Write-Host "[OK] Palace initialized" -ForegroundColor Green
Write-Host ""

# Step 3: Start MCP server
Write-Host "Step 3/4: Starting the MCP HTTP server..." -ForegroundColor Cyan
Start-Process -NoNewWindow -FilePath "mempalace-mcp" -ArgumentList "--transport","http","--host","127.0.0.1","--port","8765"
Start-Sleep -Seconds 2
Write-Host "[OK] MCP server starting on http://127.0.0.1:8765" -ForegroundColor Green
Write-Host ""

# Step 4: Configure Hermes
Write-Host "Step 4/4: Setting MemPalace as your Hermes memory provider..." -ForegroundColor Cyan

if (Test-Path $cfgFile) {
  $existing = Get-Content $cfgFile -Raw
  if ($existing -match "provider: mempalace") {
    Write-Host "[OK] MemPalace is already your Hermes memory provider" -ForegroundColor Green
  } else {
    $block = @"

# MemPalace Bridge memory provider
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
    Write-Host "[OK] MemPalace configured as your Hermes memory provider" -ForegroundColor Green
    Write-Host "  Restart Hermes for the change to take effect." -ForegroundColor Gray
  }
} else {
  Write-Host "[!] Hermes config not found at $cfgFile." -ForegroundColor Yellow
  Write-Host "Add this manually to your Hermes config file:" -ForegroundColor Gray
  Write-Host "  memory:" -ForegroundColor Gray
  Write-Host "    provider: mempalace" -ForegroundColor Gray
  Write-Host "    memory_enabled: true" -ForegroundColor Gray
  Write-Host "  mcp_servers:" -ForegroundColor Gray
  Write-Host "    mempalace:" -ForegroundColor Gray
  Write-Host "      url: http://127.0.0.1:8765/mcp" -ForegroundColor Gray
  Write-Host "      enabled: true" -ForegroundColor Gray
}
Write-Host ""

# Next steps
Write-Host "Next steps:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Expose the local MCP server through Cloudflare Tunnel:" -ForegroundColor Gray
Write-Host "     cloudflared tunnel --url http://127.0.0.1:8765" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Secure the public tunnel with a bearer token before using it in production:" -ForegroundColor Gray
Write-Host "     python -c `"import secrets; print('mcp-' + secrets.token_hex(16))`"" -ForegroundColor Cyan
Write-Host "     Save the token. Restart the server with it. See auth-token-config.yaml." -ForegroundColor Gray
Write-Host ""

Write-Host "Done. Your agents have persistent memory through MemPalace Bridge. $0." -ForegroundColor Green
Write-Host ""
