---
name: messaging-delivery
description: Send files, media, voice notes, and text to 77 across Telegram, Feishu, and Weixin. Covers home channel setup, the MEDIA file-prefix syntax, send_message action=list discovery, and the gateway config-reload gotcha.
---

# Messaging and File Delivery to 77

77 is reachable on **Telegram** (dm handle `Fiee_77`, chat_id `7580663639` — home channel), **Feishu** (2 dms), and **Weixin** (dm). When 77 asks for a file or content, deliver it directly via messaging — do not make him go fetch it himself.

## When to use this skill

- 77 says "发给我" / "send me" / "push this" / "发到飞书/微信/telegram" — anything that moves content from Hermes to his messenger.
- A tool produced a file (image, audio, video, document) and 77 should see it.
- Cron jobs or autonomous loops need to surface results.

## Quick path: send a file

1. **If you know the platform and chat_id**, send directly with explicit target:
   ```
   send_message(action='send', target='telegram:Fiee_77',
                message='<one-line caption>\nMEDIA:/absolute/path/to/file')
   ```
2. **If home channel is configured** (next session after set), you can use bare platform name:
   ```
   send_message(action='send', target='telegram', message=...)
   ```
3. **If neither works**, run `send_message(action='list')` to discover available chat_ids, then send with explicit target.

## Discovery commands

```bash
# Find all reachable chat_ids across platforms
send_message(action='list')

# Set a home channel for future sessions
hermes config set TELEGRAM_HOME_CHANNEL Fiee_77
```

## Critical gotchas

- **Config reload lag**: `hermes config set TELEGRAM_HOME_CHANNEL ...` writes the config file, but **the running gateway does NOT pick it up mid-session**. A bare `target='telegram'` send right after the config command can still fail with "No home channel set". Workaround: use explicit `target='telegram:Fiee_77'` (or the chat_id directly) for the same-session send. The home channel will work in the *next* session.
- **MEDIA prefix is a line in the message body**, not a separate parameter:
  ```
  message='Here is the file.\nMEDIA:D:\\path\\to\\file.png'
  ```
  Images (.png/.jpg/.webp) → sent as photos. Audio (.ogg) → voice bubble. Video (.mp4) → inline playback. Other files → document attachment. Use absolute paths.
- **77's workspace path**: `D:\Social\work` (NOT `C:\Users\77\work` — that path does not exist for project files). 77's project files live on the D: drive.
- **Office lock files**: `~$filename.xlsx` files in 77's work dir are temp lock files from his open Office — ignore them, do not send.
- **Tone**: 77 prefers short, direct Chinese captions. One line under the file, no preamble.

## Voice notes (TTS)

- TTS auto-configured to Chinese for 77.
- **`77` is read as "seventy-seven"** by the TTS engine — for spoken output rewrite to **"七十七"** (qī shí qī).
- `text_to_speech(text=...)` returns a `MEDIA:` path that delivers as a native voice bubble on Telegram.
- Save location defaults to `~/AppData/Local/hermes/audio_cache/<timestamp>.mp3`.

## Cron and autonomous delivery

- `cronjob(..., deliver='origin')` (default) — send to current chat/topic.
- `deliver='all'` — fan out to every connected home channel.
- `deliver='local'` — save only, no delivery.
- `deliver='platform:chat_id:thread_id'` — specific target, loses topic context if thread_id omitted.
- Cron prompts must be self-contained — no in-conversation context survives across runs.

## Sending to specific platform

```
# Telegram
target='telegram:Fiee_77'
# Feishu
target='feishu:oc_4a1994453e58aee8265eb732b98f5100'
# Weixin
target='weixin:o9cq800CX4Az88oUrY1Qv-fAAPz8@im.wechat'
```

## See also
- `references/platform-targets.md` — full chat_ids and target formats (TBD)
