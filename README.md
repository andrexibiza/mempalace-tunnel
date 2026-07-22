# mempalace-tunnel

Serve MemPalace to cloud agents via Cloudflare tunnel. Zero-cost, open-source, Hermes-native memory.

## One-command setup
```bash
pip install mempalace
mempalace init .
mempalace mcp serve --host 127.0.0.1 --port 8765
```

In another terminal:
```bash
cloudflared tunnel --url http://127.0.0.1:8765
```

That's it. Your cloud agents can now reach your local memory through the tunnel.

## Why
Local-first memory works. Cloud agents need access to it. A tunnel solves that without hosted services, API keys, or monthly fees.

## Files
- `install.sh` — Linux/macOS setup
- `install.ps1` — Windows setup  
- `cloudflare-config.yml` — annotated tunnel config template
- `LICENSE` — MIT
