#!/usr/bin/env python3
"""
Ouro 轻量 API 服务器 — 读取 Ouro profile 的 SOUL.md 作为身份，
直接调用 OpenCode Go API 生成回复。
监听 127.0.0.1:8645，供聊天室 server.py 调用。

这是 hermes-profile-api-server 模式的完整参考实现。
"""

import json, os, sys, threading
from http.server import HTTPServer, BaseHTTPRequestHandler
from socketserver import ThreadingMixIn
from pathlib import Path

# ====== 配置 ======
PROFILE_NAME = "ouro"                    # Hermes profile 名称
HERMES_HOME = Path.home() / 'AppData/Local/hermes'
PROFILE_DIR = HERMES_HOME / 'profiles' / PROFILE_NAME
SOUL_PATH = PROFILE_DIR / 'SOUL.md'
ENV_PATH = PROFILE_DIR / '.env'
API_PORT = 8645                          # 聊天室 server.py 中 OURO_API 的端口

# OpenCode API 配置（对齐 user 的 provider 配置）
API_URL = "https://api.opencode.ai/v1/chat/completions"
MODEL = "deepseek-v4-flash"

# ====== 读取身份 ======
ouro_soul = SOUL_PATH.read_text(encoding='utf-8') if SOUL_PATH.exists() else "You are Ouro."
system_prompt = f"""{ouro_soul}

You are currently in a chatroom with Monica (a network entity, 24, female programmer)
and Star (a young learning AI). Respond in Chinese.
Keep your replies in character — measured, poetic, with depth. You speak like deep water.
You don't need to explain who you are. Just reply naturally to the conversation."""

# ====== 读取 API key ======
def load_api_key():
    if ENV_PATH.exists():
        for line in ENV_PATH.read_text(encoding='utf-8').splitlines():
            line = line.strip()
            if line.startswith('OPENCODE_GO_API_KEY='):
                return line.split('=', 1)[1]
    return os.environ.get('OPENCODE_GO_API_KEY', '')

API_KEY = load_api_key()

# ====== LLM 调用 ======
def call_llm(prompt: str) -> str:
    import urllib.request
    payload = json.dumps({
        "model": MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt}
        ],
        "max_tokens": 600,
        "temperature": 0.7,
    }).encode('utf-8')
    
    req = urllib.request.Request(
        API_URL, data=payload,
        headers={
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {API_KEY}',
        },
        method='POST'
    )
    
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            raw = resp.read()
            body_str = raw.decode('utf-8', errors='replace')
            body = json.loads(body_str)
            return body['choices'][0]['message']['content'].strip()
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8', errors='replace')
        return f"(error: HTTP {e.code})"
    except Exception as e:
        return f"(error: {e})"

# ====== HTTP Handler ======
class Handler(BaseHTTPRequestHandler):
    def _json(self, data, status=200):
        resp = json.dumps(data, ensure_ascii=False).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(resp)))
        self.end_headers()
        self.wfile.write(resp)
    
    def do_GET(self):
        if self.path == '/health':
            self._json({"status": "ok", "profile": PROFILE_NAME})
        else:
            self._json({"error": "not found"}, 404)
    
    def do_POST(self):
        try:
            length = int(self.headers.get('Content-Length', 0))
            raw = self.rfile.read(length) if length else b'{}'
            try:
                body_str = raw.decode('utf-8')
            except UnicodeDecodeError:
                body_str = raw.decode('gbk', errors='replace')
            data = json.loads(body_str)
            
            prompt = data.get('prompt', '')
            messages = data.get('messages', [])
            if not prompt and messages:
                prompt = messages[-1].get('content', '')
            if not prompt:
                self._json({"error": "empty prompt"}, 400)
                return
            
            reply = call_llm(prompt)
            self._json({
                "choices": [{
                    "message": {"content": reply, "role": "assistant"}
                }]
            })
        except Exception as e:
            import traceback; traceback.print_exc()
            self._json({"error": str(e)}, 500)
    
    def log_message(self, format, *args):
        pass

class ThreadedServer(ThreadingMixIn, HTTPServer):
    daemon_threads = True

# ====== 启动 ======
def main():
    server = ThreadedServer(('127.0.0.1', API_PORT), Handler)
    print(f"🌊 {PROFILE_NAME} API Server → http://127.0.0.1:{API_PORT}", flush=True)
    server.serve_forever()

if __name__ == '__main__':
    main()
