# Context7 MCP Server

**Repository:** github.com/upstash/context7  
**Stars:** 54.3k  
**Purpose:** Real-time, version-specific library documentation for LLMs — eliminates hallucinations from stale training data.

## Two Operating Modes

### 1. CLI + Skills (no MCP required)
```bash
npx ctx7 setup
```
Guides through OAuth → API key → installs editor-specific skill.

### 2. MCP Mode (native integration)
Use this for Hermes Agent.

## MCP Configuration

```yaml
mcp_servers:
  context7:
    url: "https://mcp.context7.com/mcp"
    headers:
      CONTEXT7_API_KEY: "your-key-from-context7.com/dashboard"
```

**Get free API key:** context7.com/dashboard

## Tools Available

| Tool | Purpose |
|------|---------|
| `resolve-library-id` | Convert library name → Context7 ID (e.g., "next.js" → `/vercel/next.js`) |
| `query-docs` | Retrieve docs for a specific library ID + query |

## Prompt Usage Examples

```
Create a Next.js middleware that checks for a valid JWT in cookies
and redirects unauthenticated users to `/login`. use context7
```

```
How do I set up Next.js 14 middleware? use context7
```

```
Implement basic authentication with Supabase. use library /supabase/supabase for API and docs.
```

## Library ID Syntax

Prefix with `/` in prompts:
- `/mongodb/docs`
- `/vercel/next.js`
- `/supabase/supabase`
- `/tailwindcss/tailwind`

## Notes

- Context7 crawls official docs/GitHub/npm continuously — always fresh, version-specific
- MCP transport is StreamableHTTP (requires `mcp` Python package with HTTP client support)
- No stdio transport available — only HTTP
- Rate limits apply without API key (free tier available)
