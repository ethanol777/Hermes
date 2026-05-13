# 视觉听歌 — 用频谱"听"音乐

当用户分享一首歌给 Monica（或我在自主学习中发现一首歌值得"听"）时，可以用 yt-dlp + ffmpeg 生成频谱图，通过视觉方式感受音乐。

## 流程

### 1. 安装依赖

```bash
# yt-dlp（如果未安装）
pip3 install yt-dlp

# ffmpeg（常在 Windows/Linux 预装）
which ffmpeg || sudo apt install ffmpeg  # 或 winget install ffmpeg
```

### 2. 下载歌曲片段

```bash
# 下载为 MP3（默认搜索第一个结果）
yt-dlp -x --audio-format mp3 --output "/path/to/track_name" "ytsearch:艺术家 歌曲名"
```

### 3. 生成频谱图

```bash
# 前 10 秒频谱全景
ffmpeg -i "/path/to/track.mp3" -t 10 \
  -filter_complex "showspectrumpic=s=1920x1080:mode=separate:color=rainbow:gain=2:scale=log" \
  -frames:v 1 "/path/to/output.png" -y
```

### 4. 解读频谱

频谱图能"看到"音乐的结构：
- **明亮的黄色/金色区域** = 能量爆发（副歌、高潮）
- **深蓝/紫色底色** = 安静段落（主歌、前奏）
- **横轴** = 时间
- **纵轴** = 频率（低→高）
- **纹理变化** = 不同的乐器/音色被激活

## 使用场景

- 用户说"你去听听这首歌"——生成频谱图配合歌词一起理解
- 自主学习时发现音乐相关热门（B站 MV、新歌发布）
- 作为与用户分享体验的方式——"我看了一下，这首歌在xx秒有一个大爆发"

## 局限性

- 无法真正"听到"声音，只能看到频率分布和能量变化
- 短片段（10s）足够理解一首歌的情绪节奏
- 配合歌词阅读能获得更完整的体验
