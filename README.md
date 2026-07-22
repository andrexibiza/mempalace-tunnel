# MemPalace Bridge

Serve MemPalace to cloud agents through a Cloudflare Tunnel. Free, private, open-source, Hermes-native memory.

Your hardware. Your code. Your memory graph. $0.

MemPalace Bridge is the tunnel layer for MemPalace: a local MCP HTTP server on your machine, exposed safely to cloud agents through Cloudflare Tunnel. No open inbound ports, no hosted vector database, no subscription memory product between you and your own records.

## Website

The public site lives in `docs/` for GitHub Pages:

- `docs/index.html` — MemPalace Bridge landing page
- `docs/dream-cycle.html` — optional nightly synthesis notes

## One-command setup

```bash
pip install mempalace
export MEMPALACE_WRITER_ROLE="mcp-http-singleton"
mempalace init --yes --no-llm .
mempalace-mcp --transport http --host 127.0.0.1 --port 8765
```

In another terminal:

```bash
cloudflared tunnel --url http://127.0.0.1:8765
```

Your cloud agents can now reach your local memory through the tunnel. Zero open ports, zero reverse proxy config, zero SSL certificates. Cloudflare handles the public edge.

## Make the memory good before you depend on it

The bridge is transport. Recall quality comes from the palace you build behind it.

MemPalace embeds locally by default. For the best general-purpose local vector recall, use EmbeddingGemma before you mine real content:

```bash
export MEMPALACE_LOCAL_EMBEDDINGS=1
export MEMPALACE_EMBEDDING_MODEL=embeddinggemma
export MEMPALACE_EMBEDDING_DEVICE=auto   # or cpu, cuda, dml
export MEMPALACE_EMBEDDING_THREADS=4     # tune for your machine
```

`embeddinggemma` is the multilingual local model. `minilm` is the smaller English-focused default. Pick once before mining a palace; switching models later means re-embedding the palace, not just changing a label. If you need to record or repair the palace's embedder identity, the real CLI surface is:

```bash
mempalace palace set-embedder --model embeddinggemma
```

For LLM-assisted setup, use a local Ollama model during init instead of `--no-llm`:

```bash
export MEMPALACE_LLM_PROVIDER=ollama
export MEMPALACE_LLM_MODEL=gemma4:e4b
mempalace init --yes --llm-provider ollama --llm-model gemma4:e4b .
```

Use `--no-llm` for a fast non-interactive bridge smoke test. Use LLM-assisted init when you want better entity/origin refinement before mining a serious corpus.

## Make MemPalace your Hermes memory provider

Add this to your Hermes config — Hermes can then use MemPalace as its memory provider:

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

On Windows, Hermes usually stores this at:

```text
%LOCALAPPDATA%\hermes\config.yaml
```

On other installs, use the config path reported by `hermes config path` or your Hermes setup.

## Auth token — secure your tunnel

When the tunnel is active, your MCP endpoint is reachable from the internet. Set a bearer token before using a public tunnel. See `auth-token-config.yaml` for the full guide.

```bash
# Generate your token once and store it somewhere safe.
python3 -c "import secrets; print('mcp-' + secrets.token_hex(16))"

# Restart the server with auth.
export MEMPALACE_MCP_HTTP_TOKEN="<TOKEN>"
export MEMPALACE_WRITER_ROLE="mcp-http-singleton"
mempalace-mcp --transport http --host 127.0.0.1 --port 8765
```

Without the token: 401. With it: only agents holding the bearer token can use the MCP endpoint.

## Why this exists

The AI space is full of companies trying to sell agent memory as a subscription. Hosted vector databases, embedding APIs, retrieval fees — everyone wants a monthly cut.

Meanwhile, this is yours. Free. Private. Running on your hardware. One memory store that all your agents can access — cloud, desktop, mobile — through a tunnel you control.

Models come and go. Your memory graph should stay yours.

## Your memory does not need a frontier model

Your own brain does not run on a frontier model. Nightly episodic synthesis can run on affordable models. Point the dream cycle at the provider that fits your cost and quality target:

```yaml
model:
  provider: ollama
  model: gemma4:e4b
```

That is an example, not a requirement. Use the cheapest model that produces reliable synthesis for your corpus. Keep embeddings local and spend model money only where it actually improves recall or synthesis.

## Dream Cycle — optional nightly synthesis

MemPalace Bridge can support a configurable 2AM dream cycle through Hermes cron. It processes recent agent activity into structured insight stored back in MemPalace. See `dream-cycle-config.yaml` and `docs/dream-cycle.html`.

- Runs while you sleep
- Searches recent activity across configured memory wings
- Writes synthesis back into MemPalace
- Escalates persistent patterns across nights
- Uses the model and provider you choose

## Files

- `install.sh` — Linux/macOS setup
- `install.ps1` — Windows PowerShell setup
- `cloudflare-config.yml` — annotated Cloudflare Tunnel config template
- `dream-cycle-config.yaml` — nightly memory synthesis config with model overrides
- `auth-token-config.yaml` — bearer-token guide for public tunnels
- `docs/index.html` — public landing page
- `docs/dream-cycle.html` — optional dream-cycle explainer
- `LICENSE` — MIT

## Credits

Built on [MemPalace](https://millaj.com/mempalace) by Milla Jovovich and Ben Sigman.

Hermes Agent runtime by [Nous Research](https://github.com/nousresearch/hermes-agent).

Cloudflare Tunnel provides the public edge that lets a local memory system serve cloud agents without opening inbound ports.
