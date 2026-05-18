# FoxtrAI Video Generation Reference

Foxtrai supports video generation via a separate "视频生成" tab alongside the image generation tab.

## Available Video Models (as of 2026-05-14)

| Model | ID | Cost | Status | Notes |
|-------|-----|------|--------|-------|
| Kling 2.5 Turbo Pro | `kling-2.5-turbo-pro` | ~25 credits | ✅ Active | Based on Kling |
| Seedance 2.0 Pro | `seedance-2-pro` | 240 credits | ✅ Active | Has "全能参考" (full reference) mode. Best for reference-image-based generation. CANNOT use 风控保险. |
| Sora 2 | `sora-2` | varies | 🔧 维护中 | Based on GPT Encoding |
| Veo 3.1 Fast | `veo-3-1-fast` | varies | ✅ Active | Based on Gemini Encoding |

## Seedance 2.0 Pro — Reference Modes

Seedance 2.0 Pro has two reference modes:
- **首尾帧参考** (Start/End Frame): Upload first and last frame images. Supports adding both.
- **全能参考** (Full Reference): Upload reference images for character/style consistency.

In 全能参考 mode, the prompt has a "引用参考 智能引用" button for smart reference injection.

Settings: Duration (5s/15s), Aspect Ratio (16:9), no 风控保险 available.

## File Upload Approaches

Uploading images as reference frames for video generation faces the same challenges as image gen. Known approaches:

### Approach 1: Click upload area
Click the "添加" button under 首帧 or the upload zone. A native file dialog opens. This works if browser automation can handle the file picker, but many headless browsers cannot.

### Approach 2: JavaScript DataTransfer
Set the file on the hidden `<input type="file">` element via a DataTransfer object:
```js
const input = document.querySelector('input[type="file"]');
input.className = '';  // make visible first
input.style.display = 'block';
// Then use DataTransfer to set files
```

### Approach 3: Local HTTP server (DOES NOT WORK)
HTTPS pages (foxtrai.com) CANNOT fetch from local HTTP servers (127.0.0.1:PORT) due to:
1. **Mixed content blocking**: HTTPS page loading HTTP resources
2. **CORS**: Even with CORS headers, mixed content blocks the request before CORS is checked
Adding `Access-Control-Allow-Origin: *` headers does NOT bypass this.

### Approach 4: Asset library
The "从资产库中选择" button opens a panel showing previously generated assets in the "我的资产库" section. Assets already in the library can potentially be selected directly, bypassing file upload entirely.

## Pitfalls

- **Model must be selected first**: The UI shows different options depending on which model is active. Switch model before trying to configure reference images.
- **Seedance 240 credits cost**: Expensive. Current balance was 657 credits as of mid-May 2026.
- **No risk insurance on Seedance**: Cannot enable 风控保险 — if generation fails, credits are still consumed.
- **Peak hours**: 15:00-17:30 has higher failure rates. Avoid during this window if possible.
- **Reference image consistency**: Without a reference image, video models may not maintain character consistency across frames.

## Workflow

1. Log in to foxtrai.com
2. Click "视频生成" tab
3. Select a model from the dropdown (prefer Seedance 2.0 Pro for reference-based generation)
4. If using reference: select 全能参考 mode, upload images (see approaches above)
5. Write a detailed prompt describing the desired motion/content
6. Set duration and aspect ratio
7. Click "生成" and wait for completion
8. Download result
