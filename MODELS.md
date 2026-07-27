# OpenCode Go Model Reference

One table. Request counts per window + context + vision. Source: [opencode.ai/docs/go](https://opencode.ai/docs/go/#usage-limits).

| Model | Context | 5h | Week | Month | Vision |
|-------|---------|----|------|-------|--------|
| `deepseek-v4-flash` | 1M | **31,650** | 79,050 | 158,150 | ❌ |
| `mimo-v2.5` | 1M | **30,100** | 75,200 | 150,400 | ✅ |
| `deepseek-v4-pro` | 1M | **3,450** | 8,550 | 17,150 | ❌ |
| `qwen3.7-plus` | 1M | **4,300** | 10,800 | 21,600 | ✅ |
| `qwen3.6-plus` | 1M | **3,300** | 8,200 | 16,300 | ✅ |
| `minimax-m3` | 1M | **3,200** | 8,000 | 16,000 | ✅ |
| `mimo-v2.5-pro` | 1M | **3,250** | 8,150 | 16,300 | ❌ |
| `glm-5.2` | 1M | **880** | 2,150 | 4,300 | ❌ |
| `qwen3.7-max` | 1M | **950** | 2,390 | 4,770 | ❌ |
| `kimi-k3` | 1M | **110** | 250 | 490 | ✅ |
| `grok-4.5` | 500K | **120** | 300 | 600 | ✅ |
| `kimi-k2.7-code` | 256K | **1,350** | 3,380 | 6,750 | ✅ |
| `kimi-k2.6` | 256K | **1,150** | 2,880 | 5,750 | ✅ |
| `hy3` | 256K | **4,300** | 10,750 | 21,500 | ❌ |
| `minimax-m2.7` | 205K | **3,400** | 8,500 | 17,000 | ❌ |
| `glm-5.1` | 203K | **880** | 2,150 | 4,300 | ❌ |
| `minimax-m2.5` | 205K | **—** | — | — | ❌ |

Plan caps: **$12 / 5h**, **$30 / week**, **$60 / month**. Cheaper model = more requests per dollar.

Sources:
- [OpenCode Go docs](https://opencode.ai/docs/go/)
- [models.dev catalog](https://models.dev/catalog.json) (context + vision)
