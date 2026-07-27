# OpenCode Go Model Reference

Context window + request limits + vision support.

## Tier 1M — 1,000,000 tokens

| Model | Context | Request / 5h | Vision |
|-------|---------|--------------|--------|
| `deepseek-v4-flash` | 1M | **31,650** | ❌ |
| `mimo-v2.5` | 1M | **30,100** | ✅ |
| `deepseek-v4-pro` | 1M | **3,450** | ❌ |
| `qwen3.7-plus` | 1M | **4,300** | ✅ |
| `qwen3.6-plus` | 1M | **3,300** | ✅ |
| `minimax-m3` | 1M | **3,200** | ✅ |
| `mimo-v2.5-pro` | 1M | **3,250** | ❌ |
| `glm-5.2` | 1M | **880** | ❌ |
| `qwen3.7-max` | 1M | **950** | ❌ |
| `kimi-k3` | 1M | **110** | ✅ |

## Tier 200–500K

| Model | Context | Request / 5h | Vision |
|-------|---------|--------------|--------|
| `grok-4.5` | 500K | **120** | ✅ |
| `kimi-k2.7-code` | 256K | **1,350** | ✅ |
| `kimi-k2.5` | 256K | **1,850** | ✅ |
| `kimi-k2.6` | 256K | **1,150** | ✅ |
| `hy3` | 256K | **4,300** | ❌ |
| `minimax-m2.7` | 205K | **3,400** | ❌ |
| `minimax-m2.5` | 205K | **6,300** | ❌ |
| `glm-5.1` | 203K | **880** | ❌ |

Sources:
- [OpenCode Go docs](https://opencode.ai/docs/go/)
- [models.dev catalog](https://models.dev/catalog.json)
