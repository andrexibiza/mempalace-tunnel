# mempalace-tunnel

Serve MemPalace to cloud agents via Cloudflare tunnel. Zero-cost, open-source, Hermes-native memory.
Your hardware. Your code. Your memory graph. $0.

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

Your cloud agents can now reach your local memory through the tunnel. Zero open ports,
zero reverse proxy config, zero SSL certificates. Cloud handles all of that on the free tier.

## Make MemPalace your Hermes memory provider

Add this to `~/.hermes/config.yaml` — Hermes will auto-mine every turn to memory:

```yaml
memory:
  provider: mempalace
  memory_enabled: true

mcp_servers:
  mempalace:
    url: http://127.0.0.1:8765/mcp
    enabled: true
    connect_timeout: 180
    timeout: 180
```

No prompt injection. No voluntary retrieval. Your agents don't have to remember
to remember — Hermes handles it automatically through native MemoryProvider hooks.

## Auth token — secure your tunnel

When the tunnel is active, your MCP endpoint is reachable from the internet.
Set a bearer token. See `auth-token-config.yaml` for the full guide.

```bash
# Generate your token (save it — there's no recovery)
python3 -c "import secrets; print('mcp-' + secrets.token_hex(16))"

# Restart the server with auth
export MEMPALACE_MCP_HTTP_TOKEN="your-token-here"
mempalace mcp serve --host 127.0.0.1 --port 8765
```

Without the token: 401. With it: the tunnel is secure.

## Why this exists

The AI space is filled with companies trying to sell you agent memory as a subscription.
Hosted vector databases, embedding APIs, retrieval fees — everyone wants a monthly cut.
They're chasing revenue models that may never work out for them.

Meanwhile, this is yours. Free. Private. Running on your hardware. One memory store that
all your agents access — cloud, desktop, mobile — through a tunnel you control.

## Your memory doesn't need a frontier model

Your own brain doesn't run on GPT-5. The dream cycle (nightly episodic synthesis) runs on
affordable models. Here's the config — point it at whatever you want:

```yaml
# Dream cycle model override — add to your Hermes cron config
model: deepseek/deepseek-v4-pro          # cheap, amazing — recommended
# model: deepseek/deepseek-reasoner      # reasoning, deep synthesis
# model: openai/gpt-4o-mini              # budget alternative
# model: anthropic/claude-haiku-3.5      # another budget option
provider: deepseek                       # or openai, anthropic, etc.
```

This is personal agentic database infrastructure that grows with you. The models come
and go. The knowledge graph stays yours. Don't waste money on frontier models for memory
synthesis — cheap models do the job perfectly.

## Dream Cycle — nightly episodic synthesis

Darkloom includes a configurable 2AM dream cycle that processes your last 48 hours of
agent activity into structured insight. See `dream-cycle-config.yaml` for the full setup.

- Runs silently while you sleep
- 5 targeted searches across 6 memory wings
- Output scales to the material — not a fixed slot count
- Cross-references prior nights, escalates persistent patterns
- Any model. Any provider. You choose.

## Files

- `install.sh` — Linux/macOS setup
- `install.ps1` — Windows setup
- `cloudflare-config.yml` — annotated Cloudflare tunnel config template
- `dream-cycle-config.yaml` — nightly memory synthesis config with model overrides
- `auth-token-config.yaml` — secure your MCP server with a bearer token (required for tunnel, optional for localhost)
- `LICENSE` — MIT

## Credits

Built on [MemPalace](https://millaj.com/mempalace) by Milla Jovovich (architecture)
and Ben Sigman (engineering) — the best-benchmarked open-source AI memory system.
Hermes Agent runtime by [Nous Research](https://github.com/nousresearch/hermes-agent).
Cloudflare tunnel infrastructure. Darkloom is the integration layer that wires
them together as one coherent, free, private memory system.
