# MemPalace Bridge

Serve local MemPalace memory to cloud agents through a Cloudflare Tunnel. Free, private, open-source, Hermes-native memory.

Your hardware. Your code. Your memory graph. $0.

## What this is

[MemPalace](https://millaj.com/mempalace) is a local-first AI memory system: verbatim storage, structured wings/rooms/drawers, temporal graph records, local retrieval, and no required API calls for recall. Its public benchmark page reports **96.6% R@5 raw recall on LongMemEval** and **98.4% R@5 with the hybrid pipeline**, with the project source available at [github.com/MemPalace/mempalace](https://github.com/MemPalace/mempalace).

That solves one half of the agent-memory problem: the memory can live on your machine, under your control.

MemPalace Bridge solves the other half: cloud agents still need a way to reach that local memory surface. The bridge runs MemPalace’s MCP HTTP server on localhost, then exposes that narrow endpoint through [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/), which uses outbound-only `cloudflared` connections instead of open inbound ports.

The result is simple: a cloud agent can retrieve from your local memory without moving the whole memory system into another hosted database.

## Why it matters

The AI industry keeps trying to sell memory back to users as a subscription: hosted vector databases, embedding APIs, retrieval dashboards, and product-specific memory silos. That can be useful for teams that want managed infrastructure. It is not the only path.

Agents are more useful when they can come back tomorrow without making you restart the whole story. That requires records: exact text, scoped retrieval, durable facts, tool outputs, decisions, corrections, and enough continuity to survive model churn.

[Model Context Protocol](https://modelcontextprotocol.io/introduction) gives agent clients a standard way to connect to external tools and data sources. MemPalace gives them a local memory substrate. [Hermes Agent](https://github.com/nousresearch/hermes-agent) gives them a persistent runtime with tools, scheduled jobs, files, browser access, and real operating surface. Cloudflare Tunnel gives the public reachability layer without exposing your home machine directly.

MemPalace Bridge is the small piece between those systems.

## How the pieces fit

```text
local files / records / sessions
        ↓
MemPalace local memory graph
        ↓
mempalace-mcp --transport http --host 127.0.0.1 --port 8765
        ↓
Cloudflare Tunnel public URL
        ↓
Hermes or another MCP-capable cloud agent
```

The bridge is intentionally boring. It does not replace MemPalace, Hermes, MCP, or Cloudflare. It documents the working path that lets them cooperate.

## Website

The public site lives in `docs/` for GitHub Pages:

- `docs/index.html` — MemPalace Bridge landing page
- `docs/dream-cycle.html` — optional nightly synthesis notes

Live site: <https://andrexibiza.github.io/mempalace-tunnel/>

## Quick start

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

Your cloud agents can now reach your local memory through the tunnel. No open inbound ports, no reverse-proxy ceremony, no hosted vector database in the middle. Cloudflare handles the public edge; MemPalace stays local.

## Make the memory good before you depend on it

The bridge is transport. Recall quality comes from the palace you build behind it.

MemPalace embeds locally by default. For strong general-purpose local vector recall, use EmbeddingGemma before you mine real content:

```bash
export MEMPALACE_LOCAL_EMBEDDINGS=1
export MEMPALACE_EMBEDDING_MODEL=embeddinggemma
export MEMPALACE_EMBEDDING_DEVICE=auto   # or cpu, cuda, dml
export MEMPALACE_EMBEDDING_THREADS=4     # tune for your machine
```

`embeddinggemma` is the multilingual local model. `minilm` is the smaller English-focused default. Pick once before mining a palace; switching models later means re-embedding the palace, not just changing a label. If you need to record or repair the palace’s embedder identity, the real CLI surface is:

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

This section is about local memory setup. It is separate from the dream-cycle reasoning model below.

## Make MemPalace your Hermes memory provider

Add this to your Hermes config so Hermes can use MemPalace as its memory provider:

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

## Dream Cycle — optional nightly synthesis

Once the bridge is in place, Hermes cron can run a 2AM dream cycle: recent agent activity gets searched, synthesized, and written back into MemPalace as structured memory.

The dream cycle is retrieval, synthesis, and record keeping. Use the cheapest model that produces reliable output for your corpus. Save the expensive models for work that actually needs them. This example uses **DeepSeek V4 Pro Max** for reasoning; it is an example override, not a requirement.

```yaml
schedule: "0 2 * * *"

model:
  provider: deepseek
  model: deepseek/deepseek-v4-pro-max

max_iterations: 200
deliver: local
```

See `dream-cycle-config.yaml` and `docs/dream-cycle.html`.

A useful dream cycle should:

- run while you sleep;
- search recent activity across configured memory wings;
- synthesize findings into as many records as the material warrants;
- write durable memory back into MemPalace;
- escalate persistent patterns across nights;
- use the model and provider you choose.

## Files

- `install.sh` — Linux/macOS setup
- `install.ps1` — Windows PowerShell setup
- `cloudflare-config.yml` — annotated Cloudflare Tunnel config template
- `dream-cycle-config.yaml` — nightly memory synthesis config with model overrides
- `auth-token-config.yaml` — bearer-token guide for public tunnels
- `docs/index.html` — public landing page
- `docs/dream-cycle.html` — optional dream-cycle explainer
- `LICENSE` — MIT

## Receipts and source context

- MemPalace overview and benchmark context: <https://millaj.com/mempalace>
- MemPalace source: <https://github.com/MemPalace/mempalace>
- MCP protocol overview: <https://modelcontextprotocol.io/introduction>
- Hermes Agent runtime: <https://github.com/nousresearch/hermes-agent>
- Cloudflare Tunnel docs: <https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/>

## Credits

Built on [MemPalace](https://millaj.com/mempalace) by Milla Jovovich and Ben Sigman.

Hermes Agent runtime by [Nous Research](https://github.com/nousresearch/hermes-agent).

Cloudflare Tunnel provides the public edge that lets a local memory system serve cloud agents without opening inbound ports.
