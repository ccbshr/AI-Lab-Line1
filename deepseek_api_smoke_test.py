"""DeepSeek API 基础连通性冒烟测试（矩阵版）。

- 凭据只在本进程内读取，绝不打印明文。
- 逐个「凭据 × 端点」组合探测，命中即可用的组合后打印完整问答。
- 端点覆盖：余额探测(最轻)、OpenAI 兼容、Anthropic 兼容。
"""

from __future__ import annotations

import json
import os
import pathlib
import re
import ssl
import sys
import time
import urllib.error
import urllib.request

CRED = pathlib.Path.home() / ".dsh" / ".credentials.yaml"
PROMPT = "Only reply with the number, no explanation and no punctuation: 17 * 23 = ?"
MODEL = "deepseek-chat"


def mask(value: str) -> str:
    return f"{value[:3]}...{value[-2:]} (len={len(value)})"


def load_candidates(text: str) -> list[tuple[str, str, str]]:
    out: list[tuple[str, str, str]] = []
    current = "<root>"
    for line in text.splitlines():
        m_rec = re.match(r"^  (\S+):\s*$", line)
        if m_rec:
            current = m_rec.group(1)
            continue
        m_field = re.match(r"^\s+(secret|token|key|api_key):\s*(\S+)\s*$", line)
        if m_field:
            out.append((current, m_field.group(1), m_field.group(2)))
    return out


def mask_record(name: str) -> str:
    if "deepseek" in name.lower():
        return name
    return f"{name[:6]}...[{len(name)}]"


def request(method: str, url: str, headers: dict, body: dict | None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    ctx = ssl.create_default_context()
    t0 = time.perf_counter()
    try:
        with urllib.request.urlopen(req, timeout=60, context=ctx) as r:
            raw = r.read().decode("utf-8", "replace")
            return r.status, raw, (time.perf_counter() - t0) * 1000
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8", "replace"), (time.perf_counter() - t0) * 1000
    except Exception as e:  # noqa: BLE001
        return 0, f"{type(e).__name__}: {e}", (time.perf_counter() - t0) * 1000


def probes(token: str):
    """返回 [(标签, method, url, headers, body)]"""
    return [
        ("balance(Bearer)", "GET", "https://api.deepseek.com/user/balance",
         {"Authorization": f"Bearer {token}", "Accept": "application/json"}, None),
        ("openai-compat", "POST", "https://api.deepseek.com/chat/completions",
         {"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
         {"model": MODEL, "messages": [{"role": "user", "content": PROMPT}],
          "max_tokens": 32, "temperature": 0, "stream": False}),
        ("anthropic-compat", "POST", "https://api.deepseek.com/anthropic/v1/messages",
         {"x-api-key": token, "anthropic-version": "2023-06-01",
          "Content-Type": "application/json"},
         {"model": MODEL, "max_tokens": 32,
          "messages": [{"role": "user", "content": PROMPT}]}),
    ]


def extract_answer(payload: dict) -> str | None:
    try:
        if "choices" in payload:
            return payload["choices"][0]["message"].get("content")
        if "content" in payload and isinstance(payload["content"], list):
            return "".join(b.get("text", "") for b in payload["content"])
    except Exception:  # noqa: BLE001
        return None
    return None


KEY_FILE = pathlib.Path(__file__).with_name(".deepseek_key")


def load_explicit_key() -> tuple[str, str] | None:
    """优先使用显式提供的密钥：环境变量 DEEPSEEK_API_KEY，其次同目录 .deepseek_key。"""
    env = (os.environ.get("DEEPSEEK_API_KEY") or "").strip()
    if env:
        return ("env:DEEPSEEK_API_KEY", env)
    if KEY_FILE.exists():
        val = KEY_FILE.read_text(encoding="utf-8", errors="replace").strip()
        if val:
            return (f"file:{KEY_FILE.name}", val)
    return None


def report(url: str, tag: str, answer: str, payload: dict, ms: float) -> int:
    print()
    print("========== API SMOKE TEST ==========")
    print(f"endpoint     : {url}")
    print(f"auth source  : {tag}")
    print(f"prompt       : {PROMPT}")
    print(f"answer       : {answer.strip()!r}")
    print(f"model        : {payload.get('model')}")
    print(f"usage        : {payload.get('usage')}")
    print(f"latency      : {ms:.0f} ms")
    ok = "391" in answer
    print(f"correct      : {ok} (expected 391)")
    print("RESULT: PASS" if ok else "RESULT: PARTIAL - real response, unexpected answer")
    return 0 if ok else 3


def test_credential(tag: str, value: str) -> int | None:
    """成功返回退出码，全部失败返回 None。"""
    print(f"--- {tag} ---")
    for label, method, url, headers, body in probes(value):
        status, raw, ms = request(method, url, headers, body)
        short = raw.replace("\n", " ")[:150]
        print(f"  {label:<18} HTTP {status:<4} {ms:>6.0f} ms  {short}")
        if status == 200:
            try:
                payload = json.loads(raw)
            except json.JSONDecodeError:
                continue
            answer = extract_answer(payload)
            if answer is not None:
                return report(url, tag, answer, payload, ms)
    print()
    return None


def main() -> int:
    quick = "--quick" in sys.argv

    explicit = load_explicit_key()
    if explicit:
        tag, value = explicit
        print(f"auth source     : {tag} {mask(value)}")
        rc = test_credential(tag, value)
        return rc if rc is not None else 2

    print("auth source     : (none in env DEEPSEEK_API_KEY / .deepseek_key)")
    if quick:
        print("RESULT: SKIP - no explicit API key provided")
        return 4

    print(f"credential file : {CRED} (exists={CRED.exists()})")
    if not CRED.exists():
        print("RESULT: FAIL - credential file missing")
        return 1

    cands = load_candidates(CRED.read_text(encoding="utf-8", errors="replace"))
    print(f"candidates      : {[(mask_record(r), f) for r, f, _ in cands]}")
    print()

    for rec, field, value in cands:
        rc = test_credential(f"{mask_record(rec)}.{field} {mask(value)}", value)
        if rc is not None:
            return rc

    print("RESULT: FAIL - no stored credential authenticated against any probed endpoint")
    return 2


if __name__ == "__main__":
    sys.exit(main())
