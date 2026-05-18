---
name: rimworld-mod-audit
description: >-
  Audit RimWorld Steam Workshop mod directories — extract metadata from About.xml,
  categorize by function, detect duplicates, identify conflicts. For mod list reviews,
  cleanup sessions, and compatibility checks before adding new mods.
category: gaming
tags:
  - rimworld
  - steam-workshop
  - mod-management
  - duplicate-detection
  - xml-parsing
---

# RimWorld Mod Audit

Analyze and clean up RimWorld mod installations from Steam Workshop cache.

## Workshop Structure

Steam Workshop mods for RimWorld (appid **294100**) live under:
```
D:\Fun\Steam\steamapps\workshop\content\294100\
```
Each subdirectory is a numeric Steam Workshop ID containing version folders and:
```
About/About.xml            ← mod metadata (name, packageId, author, description, searchTags, category)
About/Preview.png          ← workshop thumbnail
Languages/                 ← translation files
```

## Parsing About.xml

Simple regex extraction works (well-formed XML, single-line tags):

```python
import re

with open(about_path, "r", encoding="utf-8") as f:
    content = f.read()

name = re.search(r'<name>(.*?)</name>', content)
pkg  = re.search(r'<packageId>(.*?)</packageId>', content)
tags = re.search(r'<searchTags>(.*?)</searchTags>', content)
```

Key fields:
- **`<name>`**: Display name in mod list
- **`<packageId>`**: Unique identifier (`Author.ModName`). Used for dependency tracking and duplicate detection.
- **`<author>`**: Creator name
- **`<searchTags>`**: Comma-separated category keywords (not all mods have this)
- **`<description>`**: Free text description
- **`<supportedVersions>`**: RimWorld versions this mod supports

## Duplicate Detection Patterns

RimWorld's mod ecosystem has several common repeat patterns:

### 1. Exact Duplicates — Same packageId, different workshop dirs
A single mod uploaded twice (Steam bug, or author re-upload). 100% conflict.
- **Detect**: group by `packageId`, flag groups with >1 entry
- **Fix**: delete the older/duplicate directory

### 2. Multi-Version — Same mod, different RimWorld version uploads
Author uploaded separate entries for e.g. `1.5` and `1.6`. The old one is dead weight.
- **Detect**: normalized name matches, same author, different workshop IDs
- **Signal**: names like `ModName (Continued)`, `ModName [1.6]`, `ModName Unoffical (1.6)`
- **Fix**: keep the newest version (highest supported version or latest upload date)

### 3. Continued/Forked — Abandoned mod picked up by another author
Original + Mlie/other maintainer fork. Usually **not compatible** together.
- **Detect**: same normalized name, different packageId namespace
- **Signal**: names ending in `(Continued)`, `(Forked)`, `(Unofficial)`
- **Fix**: pick one (prefer the actively maintained fork)

### 4. Translation Packs — Same mod with multiple Chinese translation variants
Many Chinese translators (leafzxg, MZMGOW, Shavius, 火腿, 子午线) make separate packs.
- **Detect**: name contains `汉化`, `zh-pack`, `-zh`, `_zh`, `简体中文`, `简繁汉化`
- **Fix**: one translation per mod is sufficient; multiple translators' packs for the same mod are redundant

### 5. Competing Ecosystems — Different mods doing the same thing
Independent mods with overlapping function. Not exact duplicates but functionally incompatible.
- **Examples**: LWM's Deep Storage vs Adaptive Storage vs OgreStack vs [sbz] Neat Storage
- **Examples**: RocketMan vs Performance Optimizer vs FPS Stabilizer
- **Examples**: Yayo's Animation vs Melee Animation
- **Examples**: RimDark 40k vs GrimWorld 40,000

## Functional Categorization

Use keyword matching on mod name + description + tags + packageId. Priority-order categories for RimWorld:

| Priority | Category | Keywords |
|----------|----------|----------|
| 1 | Translation packs | 汉化, zh-pack, -zh, _zh, 简体中文, 简繁汉化 |
| 2 | Vanilla Expanded | vanill(a|ia) + expand(ed|ing) |
| 3 | Frameworks/Libraries | harmony, framework, library, 前置, hugslib, jecstools |
| 4 | Performance | performance, optimiz, fps, tps, rocketman |
| 5 | UI/HUD | ui, hud, rimhud, interface, menu, tooltip, icon, bubble, portrait |
| 6 | Storage/Logistics | storage, haul, stack, ogre, fridge, shelf, container, 仓储, 搬运 |
| 7 | Combat/Weapons | combat, weapon, gun, ammunition, 弹药, turret, 炮塔 |
| 8 | Animals | animal, creature, beast, 动物, fauna, alpha animal |
| 9 | Races/Factions | race, faction, 种族, 派系, ratkin, kiiro, moyo |
| 10 | Mechs/Robots | mechanoid, mechanitor, mech, drone, robot, android, silversol |
| 11 | Production/Industry | craft, industry, manufactur, factory, rimefeller, oil |
| 12 | Magic/Psycast | psycast, psychic, magic, 魔法, 心灵, 灵能 |
| 13 | Medical/Organs | medical, organ, harvest, surgery, prosthetic |
| 14 | World/Map | world, map, biome, terrain, road, river, travel |
| 15 | Events/Incidents | event, incident, quest, story, mo'event |
| 16 | AI/Behavior | ai, behavior, common sense, work, job, auto |
| 17 | Textures/Visuals | texture, retexture, 贴图, 美化, animation, facial |
| 18 | Vehicles | vehicle, 载具, carl, tank, ship, grav |
| 19 | Power/Energy | power, energy, electricity, solar, wind, reactor |
| 20 | Temperature/AC | temperature, cooling, heating, vent, air conditioner |

## Conflict Risk Matrix

| Combine these | Risk | Notes |
|--------------|------|-------|
| RocketMan + Performance Optimizer | HIGH | Both patch same systems |
| LWM's Deep Storage + Adaptive Storage | HIGH | Same slot system |
| LWM's Deep Storage + OgreStack | MEDIUM | Stack mod + deep storage can meet |
| Moyo 1.4 + Moyo 1.6 | CRITICAL | Same mod, two versions |
| RimDark 40k + GrimWorld 40k | HIGH | Same universe, different frameworks |
| Yayo Animation + Melee Animation | HIGH | Both replace combat animations |
| Vanilla Expanded Faction mods | NONE | Designed as a compatible set |
| Alpha series (Animals/Memes/Biomes/Mechs) | LOW | By same author, tested together |

## Common Pitfalls

- **Don't trust `searchTags` exclusively**: many mods omit this field
- **Watch for `brrainz.harmony` in packageId**: it's the Harmony dependency injected automatically, not a real author namespace
- **Translation packs require the base mod**: they are not standalone
- **`(Continued)` mods by Mlie** are often the best-maintained versions; prefer them over abandoned originals
- **Vanilla Expanded Framework is a hard dependency** for ALL Vanilla Expanded mods
- **PackageId matching is case-sensitive** in RimWorld; normalize to lowercase for comparison
