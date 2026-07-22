# mempalace-tunnel — Windows setup (PowerShell)
# One-command bootstrap for MemPalace + Cloudflare tunnel

Write-Host "==> Installing MemPalace..." -ForegroundColor Cyan
pip install mempalace

Write-Host "==> Initializing MemPalace in current directory..." -ForegroundColor Cyan
mempalace init .

Write-Host "==> Starting MemPalace MCP HTTP server on port 8765..." -ForegroundColor Cyan
Start-Process -NoNewWindow -FilePath "mempalace" -ArgumentList "mcp serve --host 127.0.0.1 --port 8765"

Write-Host "==> Starting Cloudflare tunnel (requires cloudflared on PATH)..." -ForegroundColor Cyan
Write-Host "    Run this in a separate terminal:"
Write-Host "    cloudflared tunnel --url http://127.0.0.1:8765"
Write-Host ""
Write-Host "Done. Your memory is now tunneled to the cloud." -ForegroundColor Green
Write-Host ""
Write-Host "Next: set up the dream cycle — edit dream-cycle-config.yaml" -ForegroundColor Cyan
Write-Host "      and add it to your Hermes cron config. Use any model." -ForegroundColor Cyan
