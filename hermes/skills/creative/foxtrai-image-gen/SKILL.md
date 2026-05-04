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

## Important Notes

- **Model cost**: GPT Image 2 costs 7 credits per generation
- **Account balance**: Currently 10 credits remaining (was 17, spent 7)
- **Generate button**: May say "生成需消耗 7" — ensure balance is sufficient
- **No vision analysis**: The DeepSeek provider doesn't support image vision — use browser_console() or DOM inspection to check results instead of browser_vision()
- **Download location**: Files go to ~/Downloads/foxtrai-asset-*.png on WSL
- **Image hosting**: Only send via Feishu IM (WeChat MEDIA: send fails due to platform bug)

## Prompt Writing Tips for Bazi Charts

When generating Bazi (八字) charts, include in the prompt:
1. Traditional Chinese aesthetic (dark background, gold/red palette, scroll-like border)
2. 4-column table layout (时柱, 日柱, 月柱, 年柱)
3. Each cell: upper row = 天干 (big bold characters), lower row = 地支
4. Below each pillar: hidden stems + ten gods (藏干十神)
5. Bottom info: birth date, 日主 analysis, wuxing stats, 大运 timeline
6. Set font rendering requirements for Chinese characters
