---
name: foxtrai-image-gen
description: Use foxtrai.com with GPT Image 2 to generate images, download them, and send via Feishu. Covers login, model selection, prompt writing, generation, download, and Feishu delivery.
---

# FoxtrAI Image Generation Skill

Use foxtrai.com (https://www.foxtrai.com) to generate images via GPT Image 2 model, then deliver to user via Feishu.

## Prerequisites

- Foxtrai account credentials saved in memory (email + password)
- Feishu app configured with App ID/Secret in ~/.hermes/.env
- User's Feishu open_id (look up via contact API if needed)

## Workflow

### Step 1: Navigate and Login

1. Open `https://www.foxtrai.com` in browser
2. Click the "登录" button
3. Fill in email and password credentials
4. Click "立即登录"
5. Dismiss any popup modals (click "我知道了" / close button)

### Step 2: Select GPT Image 2 Model

1. Click the current model button (default: "nano-banana-pro") to open model dropdown
2. Click "gpt-image-2" (GPT Image 2) option — based on ChatGPT Encoding
3. Verify the model name now shows "GPT Image 2"

### Step 3: Write Prompt

Write a detailed prompt in the prompt textbox. Include:
- Clear visual description of what to generate
- Style, color scheme, layout details
- Any specific text or Chinese characters needed
- Aspect ratio consideration (use "生成比例 自动" by default)

### Step 4: Generate

1. Click the "生成" (Generate) button
2. Wait for progress to reach 100% — the task shows "%" progress indicator
3. Generation typically takes 30-60 seconds depending on size/quality

### Step 5: Download

1. Once complete, click the "下载" (Download) button on the generated image
2. The file saves to ~/Downloads/foxtrai-asset-*.png

### Step 6: Send via Feishu

1. Get fresh Feishu tenant_access_token
2. Upload image to Feishu: `POST /open-apis/im/v1/images` (form-data: image_type=message, image=@path)
3. Send image message: `POST /open-apis/im/v1/messages?receive_id_type=open_id`
   - receive_id: user's Feishu open_id
   - msg_type: "image"
   - content: {"image_key": "<returned_image_key>"}

## Balance Management

- **Starting balance**: 17 credits
- **GPT Image 2 cost**: 7 credits per generation at 1K quality, 中档
- **Current balance**: Check at top of sidebar (shows "X 账户余额")
- **When balance < cost**: The "生成" button changes to disabled "余额不足" — need to recharge before generating
- **Balance drops immediately** after clicking generate (before generation completes)
- **Other models cost**: nano-banana / nano-banana-2 / nano-banana-pro costs 8 credits
- **Free generation**: If Banana Pro model has resolution downgrade, the generation is free (no charge)

## Important Notes

- **No vision analysis**: The DeepSeek provider doesn't support image vision — use browser_console() or DOM inspection (check for img presence + download button) to verify completion instead of browser_vision()
- **Download location**: Files go to ~/Downloads/foxtrai-asset-*.png on WSL
- **Image hosting**: Only send via Feishu IM (WeChat MEDIA: send fails due to platform bug)
- **History**: Previous generations appear in "历史记录" section on the right side
- **Modal popups**: "发现新版本" modal appears on fresh login — dismiss with "我知道了" before interacting

## Prompt Types & Templates

### Type 1: Bazi (八字) Charts

When generating Bazi charts, include in the prompt:
1. Traditional Chinese aesthetic (dark background, gold/red palette, scroll-like border)
2. 4-column table layout (时柱, 日柱, 月柱, 年柱)
3. Each cell: upper row = 天干 (big bold characters), lower row = 地支
4. Below each pillar: hidden stems + ten gods (藏干十神)
5. Bottom info: birth date, 日主 analysis, wuxing stats, 大运 timeline
6. Specify font rendering requirements for Chinese characters

### Type 2: Character / Mascot Art

When generating cute characters or mascots, include in the prompt:
1. Character description (animal type, color, size, expression)
2. Outfit/accessories (crown, cape, hat, props)
3. Pose and posture (standing, sitting, hands on hips, waving)
4. Background style (gradient, starry, solid color, patterned)
5. Art style (Japanese anime, chibi, watercolor, vector flat)
6. Color palette (warm/cool, specific dominant colors)
7. Text/label if any (Chinese art text, position, font style, border color)
8. Aspect ratio (square for avatars, portrait for full body, landscape for scenes)

### Type 3: Landscape / Scene

For scenery, architecture, or environmental art:
1. Setting (time of day, weather, season)
2. Foreground/midground/background layering
3. Color atmosphere (golden hour, cyberpunk neon, misty morning)
4. Artistic style (Chinese ink wash, anime background, photorealistic)

### Type 4: Diagram / Infographic

For technical diagrams or information graphics:
1. Clean white/light background for readability
2. Chinese text support — specify exact characters and font style
3. Structured layout with sections and connecting arrows
4. Color-coded categories for different elements
