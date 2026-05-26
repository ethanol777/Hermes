# Steam Workshop Scraping Notes

## Collection API Endpoint

Steam exposes workshop collections as JSON:

```
https://steamcommunity.com/sharedfiles/collectiondetails/?collectioncount=1&publishedfileids[0]={COLLECTION_ID}&format=json
```

Try with `l=schinese` or `l=english` for language variants.

**Known issues:**
- Returns gzip-compressed content — decompress first
- Often connection-reset when hit from datacenter IPs
- JSON endpoint may return non-UTF-8 encoded bytes (Chinese chars) — handle `UnicodeDecodeError`
- `browser_navigate` to this endpoint produces encoding errors: `'utf-8' codec can't decode byte`

## Steam Workshop Collection Pages

The standard browsable page:
```
https://steamcommunity.com/sharedfiles/filedetails/?id={COLLECTION_ID}
```

**Known issues with Hermes browser tools on Steam:**
- `browser_snapshot` truncates at ~456 elements on collection pages (lazy-loaded items beyond fold are not rendered)
- `browser_console` JavaScript execution returns `null` on Steam community pages
- Raw HTML curl/node requests get `ECONNRESET` or empty response
- `PowerShell Invoke-WebRequest` times out
- `python urllib` hits SSL errors or connection resets

**What works:**
- `browser_navigate` + `browser_snapshot` can read the first ~5-10 visible mod items before truncation
- Steam's JSON API (`/collectiondetails/`) works from a logged-in browser session but may have encoding issues
- Search engines may surface mirrors or cached versions of the mod list

## Workarounds

1. **For mod list extraction**: Use the Steam mobile app or Steam client overlay to copy the mod list — both render the full collection without lazy-load truncation.

2. **For single mod details**: Navigate to individual mod pages (`filedetails/?id={MOD_ID}`) — these load fully and aren't truncated.

3. **For collection summaries**: Check the collection's description/comments for manually posted mod lists by other users.

4. **For research**: SteamDB (steamdb.info) and SteamChart (steamcharts.com) have better programmatic access than Steam's own site.

5. **Search for mirrors**: Try querying "site:nga.cn" or "site:tieba.baidu.com" + the collection name in Chinese for community-curated mod lists.

## Specific Collection Reference

- **Collection ID**: `1953528481`
- **Name**: "Kenshi 新手起始" (Kenshi Beginner Starter)
- **Size**: 77 items
- **Categories**: Buildings, Gameplay, Clothing/Armour, Factions, Translation, Items/Weapons, Research, Graphical, Races, GUI
- **Note**: Collection author marked Umbra Backpacks as "异常作弊" (unbalanced/cheaty) — provides high-capacity backpacks with abilities from shops

## Generic Anti-Bot Patterns

Steam uses:
- IP-based rate limiting and blocking
- Browser fingerprinting (headless detection)
- WebSocket/header validation

For anything beyond trivial access, use `StealthyFetcher` from the scrapling library with:
- `solve_cloudflare=True`
- Residential proxy rotation if available
- Impersonation mode set to a real Chrome/Edge browser profile
