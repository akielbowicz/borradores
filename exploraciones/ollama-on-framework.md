# The definitive Ollama setup guide for a 64GB Framework Laptop 13

**Your Framework 13 with Ryzen 7 7840U and 64GB DDR5 is a capable local LLM workstation, with one game-changing discovery: Mixture-of-Experts models like Qwen3-30B-A3B deliver 32B-class quality at 7B-class speed.** The practical sweet spot is 7B–14B dense models for interactive use (10–17 tokens/sec), while the 30B MoE model achieves **12–15 tok/s** by activating only 3.3B parameters per token. Running 70B models is technically possible but painfully slow at ~1.3 tok/s. The AMD 780M iGPU can accelerate small models by 25–43% through a ROCm workaround or the newer Vulkan backend, though CPU-only inference is the most reliable path for larger models. Ollama v0.17, released February 22, 2026, brings up to 40% faster prompt processing and native KV cache quantization — both directly beneficial for this setup.

---

## Hardware optimization: squeezing performance from the 780M and Zen 4

### The iGPU question — worth it, but only for small models

The AMD Radeon 780M (gfx1103) is **not officially supported** by Ollama's ROCm backend. However, two proven acceleration paths exist:

**ROCm workaround.** Setting `HSA_OVERRIDE_GFX_VERSION=11.0.2` forces ROCm to treat the 780M as a compatible gfx1102 device. Multiple Framework 13 users confirm this works on Linux, with the iGPU detected as having **~20GB accessible VRAM** (shared from system RAM) on 64GB systems. Direct benchmarks show Llama 2 7B Q4_0 hitting **19.6 tok/s text generation and 263 tok/s prompt processing** via ROCm — a significant uplift. Note that Fedora 42+ is adding native gfx1103 ROCm support, so Fedora 43 may work without the override.

**Vulkan backend.** Set `OLLAMA_VULKAN=1` for a ROCm-free path. On a Framework 16 with the same 780M iGPU and 64GB RAM, Vulkan delivered **221 tok/s prompt processing** (vs 88 tok/s CPU-only) and **~16 tok/s text generation** (vs 12 tok/s CPU-only) for an 8B Q4_K_M model. Vulkan detects the iGPU as a unified-memory device, allowing it to use system RAM directly. However, stability issues remain — context shifting can trigger crashes on some configurations.

**The verdict:** For models that fit within ~8GB VRAM (7B–8B at Q4), iGPU offloading provides a **25–43% speedup** in token generation and 2.5× faster prompt processing. For 14B+ models, **stick with CPU-only** — partial offloading creates overhead since the iGPU shares the same DDR5 memory bus, and can cause instability. Increase your BIOS VRAM allocation to at least **4GB** (8GB if available) before attempting GPU acceleration.

### CPU inference is the backbone

The Ryzen 7840U's Zen 4 architecture with **AVX-512 support** makes it one of the best consumer CPUs for LLM inference. AVX-512 delivers roughly **10× faster prompt evaluation** compared to AVX2 — though this benefit is primarily in prompt processing (prefill), not token generation, which remains memory-bandwidth-bound.

Set thread count to **8** (matching physical cores). Hyperthreading actively hurts LLM inference — using 16 threads is slower than 8. Ollama typically auto-detects this correctly, but verify with `OLLAMA_NUM_THREADS=8`.

Your dual-channel **DDR5-5600 provides ~89.6 GB/s** theoretical bandwidth (~50–70 GB/s effective). This is the fundamental ceiling for token generation speed. For context: an M2 Max delivers 400 GB/s, and an RTX 4090 exceeds 1,000 GB/s. Every token generated requires reading the entire model from memory, so bandwidth directly determines tok/s.

### Realistic performance expectations

These numbers come from actual Framework 13 / 7840U benchmarks, primarily CPU-only:

| Model size | Quantization | RAM used | Tok/s (CPU) | Tok/s (iGPU) | Experience |
|-----------|-------------|----------|-------------|-------------|------------|
| 3–4B | Q4_K_M | ~3 GB | 19–20 | ~24 | Instant, excellent |
| 7–8B | Q4_K_M | ~5–6 GB | 11–13 | 16–17 | Fast, very interactive |
| 9B | Q4_K_M | ~6 GB | 8–9 | ~12 | Good, comfortable |
| 14B | Q4_K_M | ~10 GB | 5–7 | ~9 | Usable, slight waits |
| **30B-A3B (MoE)** | **Q4_K_M** | **~19 GB** | **12–15** | **—** | **Excellent (only 3.3B active!)** |
| 32B (dense) | Q4_K_M | ~22 GB | 2–4 | — | Slow, batch-oriented |
| 70B | Q4_K_M | ~46 GB | 1.0–1.3 | — | Painfully slow |

The **MoE breakthrough** deserves emphasis. Qwen3-30B-A3B has 30B total parameters but activates only 3.3B per token, meaning it runs at 7B speed while delivering 32B quality. On 64GB RAM, this model is the single most important discovery for your hardware.

For 70B models: they technically fit in 64GB at Q4_K_M (~42.5GB weights + ~4GB KV cache + OS overhead), but at ~1.3 tok/s, each word takes nearly a second. Practical only for batch generation you can walk away from.

---

## Model recommendations: the optimal fleet for four use cases

### Code generation — Qwen dominates

**Primary: `qwen3-coder:30b`** (MoE, ~18–21GB RAM, 12–15 tok/s). This model activates only 3.3B parameters per token yet performs comparably to Claude Sonnet on agentic coding benchmarks. It supports 256K context and was purpose-built for multi-file code generation. This is your daily driver for code — fast enough for interactive use and smart enough for complex refactors.

**Quality: `qwen2.5-coder:32b`** (~20GB RAM, 3–5 tok/s). When you need maximum code quality and can wait, this dense 32B model is competitive with GPT-4o on code repair benchmarks and supports 92+ programming languages. Use it for complex architecture decisions, thorough code review, or generating production-critical code.

**Autocomplete: `qwen2.5-coder:7b-base`** (~4.5GB RAM, 12–17 tok/s). Use the `base` (not `instruct`) variant for tab-completion in Continue.dev. Small enough to stay loaded alongside your main model.

Other strong options include `deepseek-coder-v2:16b` (MoE, 300+ languages), `codestral:22b` (Mistral's code model), and `deepcoder:14b`.

### MCP agents and tool calling — Qwen3 was built for this

**Primary: `qwen3:14b`** (~9GB RAM, 7–9 tok/s). Qwen3 has **native tool-calling support** explicitly designed for agentic workflows. Ollama's own tool-calling documentation uses Qwen3 as the primary example. It works in both "thinking" and "non-thinking" modes — use `/no_think` for faster tool responses. At 14B, it balances capability with interactive speed.

**Fast agent: `qwen3:8b`** (~5GB RAM, 12–17 tok/s). For simple tool calls where latency matters — quick file lookups, API calls, or lightweight validation steps.

**Complex workflows: `qwen3:30b-a3b`** (MoE, ~19GB RAM, 12–15 tok/s). When agents need stronger reasoning — multi-step UI validation, complex decision trees, or chaining multiple tools — this model outperforms the dense 32B Qwen while running 4× faster.

Other tool-calling models: `mistral-small:24b`, `llama3.2:3b` (ultra-lightweight), `granite4:8b` (IBM, strong structured output).

### Prose and creative writing

**Primary: `qwen3:32b`** (~20GB RAM, 3–5 tok/s). Qwen3 32B excels at creative writing, role-playing, and human-preference alignment. At 3–5 tok/s, it's slow but acceptable for generating polished prose — a 500-word blog section takes about 2 minutes.

**Interactive drafting: `qwen3:14b`** (~9GB RAM, 7–9 tok/s). Fast enough for iterative writing sessions where you're going back and forth refining content. Qwen3's 14B punches well above its weight — the Qwen3 family shows remarkable quality scaling, with Qwen3-4B rivaling Qwen2.5-72B-Instruct.

**Maximum quality drafts: `llama3.3:70b`** (~46GB RAM, ~1.3 tok/s). Load this when you want the highest-quality output and can let it run during a coffee break. Comparable to the 405B model in writing quality.

### Blog posts and long-form documents

For long-form content, the same writing models apply, but **context window management becomes critical**. The `qwen3:30b-a3b` MoE model is ideal here: at 12–15 tok/s, generating a 2,000-word blog post takes only 2–3 minutes, and its 32K native context (131K with YaRN) handles long documents well. Pair with `OLLAMA_KV_CACHE_TYPE=q8_0` to halve context memory overhead.

### Quantization: Q4_K_M is the sweet spot

| Quantization | Quality vs FP16 | Best use |
|-------------|-----------------|----------|
| **Q4_K_M** | ~95% | **Gold standard** — best quality/speed/RAM tradeoff |
| Q5_K_M | ~97% | Premium quality for 14B and smaller models |
| Q6_K | ~98–99% | Near-original for quality-critical tasks on ≤14B |
| Q8_0 | ~99.5% | Maximum quantized quality; use for 7B models |
| Q3_K_M | ~88–90% | Avoid — noticeable degradation |

A critical insight: **a larger model at Q4_K_M consistently outperforms a smaller model at Q8_0**. Running Qwen3-32B at Q4_K_M produces better output than Qwen3-14B at Q8_0. With 64GB RAM, use Q4_K_M for 30B+ models and Q5_K_M or Q6_K for 14B and smaller.

---

## Ollama configuration for a 64GB Bluefin system

### Installation on Bluefin (immutable Linux)

Bluefin provides first-class AI tooling. The recommended installation methods, in order of preference:

**`ujust ollama`** — Bluefin's native command installs Ollama as a Podman container managed by user systemd. It prompts for ROCm or CPU-only mode. Start with `systemctl --user start ollama`. This is the cleanest path on an atomic OS.

**`ujust ollama-web`** — Installs both Ollama and Open WebUI as containers in one command.

**Podman Quadlet** for more control — create `~/.config/containers/systemd/ollama.container`:

```ini
[Unit]
Description=Ollama LLM Server
After=local-fs.target

[Container]
ContainerName=ollama
Image=docker.io/ollama/ollama:latest
Volume=ollama:/root/.ollama
PublishPort=11434:11434
Environment=OLLAMA_FLASH_ATTENTION=1
Environment=OLLAMA_KV_CACHE_TYPE=q8_0
Environment=OLLAMA_KEEP_ALIVE=30m
Environment=OLLAMA_NUM_PARALLEL=4
Environment=OLLAMA_MAX_LOADED_MODELS=3
Environment=OLLAMA_CONTEXT_LENGTH=8192

[Service]
Restart=always

[Install]
WantedBy=default.target
```

For ROCm iGPU acceleration, use the `ollama:rocm` image and add:
```ini
AddDevice=/dev/kfd
AddDevice=/dev/dri
Environment=HSA_OVERRIDE_GFX_VERSION=11.0.2
```

Bluefin also ships **Ramalama** (`brew install ramalama`), **Goose** (agentic CLI), and **Alpaca** (Flatpak GUI) as companion AI tools.

### Environment variables explained

| Variable | Recommended value | Why |
|----------|-------------------|-----|
| `OLLAMA_FLASH_ATTENTION` | `1` | Reduces KV cache memory, zero quality loss. **Always enable.** |
| `OLLAMA_KV_CACHE_TYPE` | `q8_0` | Halves KV cache RAM vs f16. Minimal quality impact. |
| `OLLAMA_NUM_PARALLEL` | `4` | Concurrent requests. 4 is safe for 64GB with 8B–14B models. |
| `OLLAMA_MAX_LOADED_MODELS` | `3` | Keep code, writing, and agent models loaded simultaneously. |
| `OLLAMA_KEEP_ALIVE` | `30m` | Avoids cold-start latency when switching tasks. Use `-1` for always-on. |
| `OLLAMA_CONTEXT_LENGTH` | `8192` | Global default. Override per-model in Modelfiles. |
| `OLLAMA_NUM_THREADS` | `8` | Match physical cores. Verify auto-detection is correct. |

### Modelfile templates for each use case

**Code generation** (`Modelfile.code`):
```
FROM qwen3-coder:30b
PARAMETER temperature 0.2
PARAMETER num_ctx 16384
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1
SYSTEM """You are an expert software engineer. Write clean, efficient,
well-documented code. When reviewing, check for security vulnerabilities,
performance issues, and best practice violations. Provide actionable
feedback with code examples."""
```

**Agent/MCP** (`Modelfile.agent`):
```
FROM qwen3:14b
PARAMETER temperature 0.1
PARAMETER num_ctx 16384
PARAMETER top_p 0.85
PARAMETER repeat_penalty 1.05
SYSTEM """You are a precise AI assistant with access to tools. Analyze
available tools and use them methodically. Always explain your reasoning
before calling a tool. Return structured data when requested."""
```

**Creative writing** (`Modelfile.writer`):
```
FROM qwen3:32b
PARAMETER temperature 0.75
PARAMETER num_ctx 8192
PARAMETER top_k 80
PARAMETER top_p 0.95
PARAMETER repeat_penalty 1.15
SYSTEM """You are an accomplished writer. Produce engaging, well-structured
prose with vivid language and varied sentence rhythm. Match the requested
tone — whether creative, professional, or technical."""
```

Create these with `ollama create code-assistant -f Modelfile.code`, etc. With `OLLAMA_MAX_LOADED_MODELS=3` and `OLLAMA_KEEP_ALIVE=30m`, you can keep all three loaded simultaneously. **Three 14B models total ~30GB** — well within budget. Even a 30B MoE + 14B + 7B combination fits at ~33GB with room to spare.

---

## MCP and agentic workflows with local Ollama

### Connecting Ollama to MCP servers

Ollama has **no native MCP implementation** as of v0.17, but the ecosystem provides mature bridge solutions:

**mcphost** (Go-based, recommended for CLI workflows) connects Ollama directly to any MCP server:
```bash
go install github.com/mark3labs/mcphost@latest
mcphost -m ollama:qwen3:14b --config mcp-config.json
```

**ollama-mcp-bridge** (TypeScript) bridges Ollama to MCP servers with smart tool detection. **ollmcp** provides a full terminal UI with agent mode and human-in-the-loop safety controls. **Dolphin MCP** is a Python library supporting Ollama, OpenAI, and Anthropic providers.

### UI validation with Playwright MCP

For MCP-based UI validation, the **Playwright MCP server** (by Microsoft) is the primary tool:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

It works by reading the browser's **accessibility tree** — a structured text representation of UI elements — rather than relying on screenshots. This is fast, token-efficient, and works well with local models. For visual validation (canvas elements, complex layouts), it supports a Vision mode with screenshot capture. The workflow looks like: launch Playwright MCP → connect via mcphost or Continue.dev → prompt the model to navigate pages, verify elements exist, check form behavior, and report issues. A tool-calling model like **Qwen3:14b** handles this effectively.

### Framework compatibility matrix

| Tool | Ollama support | MCP support | Best for |
|------|---------------|-------------|----------|
| **Continue.dev** | Native | Yes (config.yaml) | Code completion + chat in VS Code |
| **Open WebUI** | Native | Yes (via MCPO proxy) | Web-based chat, RAG, documents |
| **LangChain/LangGraph** | Via langchain-ollama | Via adapters | Complex agent state machines |
| **CrewAI** | Native | Via tools | Multi-agent role-based collaboration |
| **Goose** (Bluefin default) | Native | Native | General-purpose agentic CLI |
| **mcphost** | Native | Native | Direct MCP CLI integration |

### Continue.dev setup for VS Code

Continue.dev is the recommended code assistant. Configure `~/.continue/config.yaml`:

```yaml
models:
  - name: Qwen3 Coder
    provider: ollama
    model: qwen3-coder:30b
    roles: [chat, edit]
  - name: Qwen Autocomplete
    provider: ollama
    model: qwen2.5-coder:7b-base
    roles: [autocomplete]
    autocompleteOptions:
      debounceDelay: 350
mcpServers:
  - name: Playwright
    command: npx
    args: ["@playwright/mcp@latest"]
  - name: Filesystem
    command: npx
    args: ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/project"]
```

This gives you inline autocomplete from the fast 7B model, chat/edit from the powerful 30B MoE coder, and MCP tool access for browser automation and file operations — all running locally.

---

## The ecosystem in early 2026: what's new and what matters

**Ollama v0.17** (released February 22, 2026) is the largest update in Ollama's history. It replaces the direct llama.cpp server mode with a new inference engine that wraps llama.cpp as a library, yielding up to **40% faster prompt processing** and **18% faster token generation** on supported GPUs. KV cache quantization to 8-bit is now built-in, roughly halving cache overhead. The release also adds RDNA 4 support (Radeon RX 9070 series) and improved multi-GPU concurrency. New features include `ollama launch` for integrating with Claude Code, Codex, and other tools, plus a built-in web search API for RAG.

**llama.cpp improvements** directly benefiting CPU inference include flash attention across all backends (Vulkan, CUDA, Metal, SYCL), extensive KV cache quantization options (q8_0, q4_0, q5_0, and more), weight layout reordering for better cache utilization, and NUMA-aware scheduling. The Vulkan backend has matured significantly, with cooperative matrix extensions and proper UMA device detection for iGPUs.

**AMD APU developments** are trending positive but slowly. AMD's newer Ryzen AI 300 series introduced Variable Graphics Memory (VGM), allowing up to 75% of system RAM as dedicated VRAM with a **60% performance uplift** over CPU-only for small models. This feature is *not* available on the 7840U but signals where AMD is heading. The Ryzen AI Halo platform (announced January 2026) supports up to 128GB unified memory with 256 GB/s bandwidth — a future Framework Desktop target. For current hardware, the Vulkan backend remains the most practical iGPU acceleration path.

**Bluefin's AI stack** has evolved into a cohesive toolkit: `ujust ollama` and `ujust ollama-web` for one-command setup, Ramalama for model management, Goose as the primary agentic CLI, and a curated brew menu (`ujust bbrew → ai`) offering aichat, mods, claude-code, fabric, and other tools. Open WebUI v0.8+ adds RAG with 9 vector database options, 15+ web search providers, and MCP support via the MCPO proxy.

---

## Conclusion: the recommended setup

The optimal configuration for your Framework 13 centers on **three key decisions**: use CPU-only inference for models above 8B, make Qwen3-30B-A3B (MoE) your workhorse model, and enable flash attention with q8_0 KV cache quantization everywhere.

Your practical model fleet should be:

- **`qwen3-coder:30b`** — daily code generation at 12–15 tok/s (MoE magic)
- **`qwen3:14b`** — MCP agents, tool calling, and interactive writing at 7–9 tok/s
- **`qwen3:32b`** — polished prose and long-form content at 3–5 tok/s
- **`qwen2.5-coder:7b-base`** — tab-autocomplete in Continue.dev at 12–17 tok/s

All four fit in 64GB RAM (the first three total ~48GB loaded simultaneously, though you'd typically only load two at once). Install via `ujust ollama` on Bluefin, add Open WebUI with `ujust ollama-web`, set up Continue.dev in VS Code, and connect Playwright MCP for UI validation through mcphost or Continue's native MCP support.

The single non-obvious insight from this research: **MoE models have fundamentally changed what's practical on CPU-only hardware.** Qwen3-30B-A3B delivers quality that previously required a discrete GPU or cloud API, at speeds that feel interactive. This makes the 64GB Framework 13 a genuinely capable local AI workstation — not a compromise, but a deliberate choice for privacy and independence.