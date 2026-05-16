# Chinese Tech Company AI Tool Policies (For Employee Reference)

When a user asks whether they can use Codex CLI, ChatGPT, or other overseas AI tools at their workplace (especially Chinese big tech companies), here's what's generally true.

## General Pattern Across Chinese Big Tech

### Network Level
- **Intranet blocks overseas AI domains** — OpenAI, Anthropic, xAI etc. are typically firewalled at the company network level
- Employees cannot reach these services from the corporate network without VPN/proxy (which itself may violate IT policy)
- Internal AI platforms are provided as alternatives

### Data Security Level
- **Uploading internal code to foreign servers is a red line** — violates company data security policies
- Most relevant regulations: 《数据安全法》, 《个人信息保护法》
- Codex CLI sends project code to OpenAI servers = automatic policy violation if used on company code
- Consequences range from warning to termination depending on severity

### Internal Alternatives Most Companies Have

| Company | Internal LLM | External-Facing AI Product |
|---------|:-----------:|:--------------------------:|
| **Kuaishou (快手)** | **KwaiYii (快意)** — 13B/34B parameter model, open-sourced on GitHub | Kling (可灵) — video generation |
| **ByteDance (字节跳动)** | Internal LLM platform (powers 豆包 internally) | 豆包 (Doubao) |
| **Alibaba (阿里巴巴)** | Tongyi (通义千问) | 通义千问, 通义灵码 (coding assistant) |
| **Tencent (腾讯)** | Hunyuan (混元) | 混元助手 |
| **Baidu (百度)** | ERNIE (文心一言) | 文心一言 |
| **Meituan (美团)** | Internal LLM (not publicly named) | N/A |

### The Two-Zone Approach

Most Chinese tech employees operate with a "two-zone" strategy:

| Zone | Time | Device | Network | What You Can Use |
|:----:|:----:|:------:|:-------:|:----------------|
| **Work** | 9-6 | Company laptop | Company intranet | Internal AI tools only |
| **Personal** | Evenings/weekends | Personal devices | Home network | Whatever you want (Codex, ChatGPT, etc.) |

**Never**: Copy company code to personal devices or paste it into any external AI tool.

## How to Answer the User's Question

When asked "Can I use Codex at <company name>?":

1. **Explain the general pattern**: Chinese big tech companies block external AI tools on their network and have data security policies against uploading code
2. **Mention the internal alternative**: Most companies have internal LLMs employees can use
3. **Give the two-zone advice**: Use external tools on personal time/devices; use internal tools at work
4. **Recommend checking the company's AI usage policy** after joining (usually in employee handbook or internal wiki)
5. **Don't make specific claims about that company** if you don't have internal knowledge — focus on the general industry pattern

## Company-Specific Notes (Publicly Known)

### Kuaishou (快手)
- **Internal LLM**: KwaiYii (快意) — announced Aug 2023, open-sourced on GitHub (kwai/KwaiYii)
- **External product**: Kling (可灵) video generation model
- **Business impact**: Kling generated ¥300M+ revenue in Q3 2025
- The company heavily invests in AI and likely has sophisticated internal tools for employees

### Other Companies
For companies without widely publicized internal tools, it's safe to say they have *some* internal AI platform — almost all Chinese tech companies with >1000 engineers do.
