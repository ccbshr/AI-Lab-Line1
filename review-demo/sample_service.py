"""供「终端 AI 代码审查」演示用的样例文件：故意植入若干典型缺陷。

用途：在 dsh / OpenCode 里对它跑一次审查，检验工具能否找出这些问题。
"""

import logging
import threading
import time
from concurrent.futures import ThreadPoolExecutor

import requests

logger = logging.getLogger(__name__)

CACHE = {}
STATS = {"ok": 0, "fail": 0}


def fetch_user(user_id, token):
    resp = requests.get(
        f"https://api.example.com/users/{user_id}",
        headers={"Authorization": f"Bearer {token}"},
        verify=False,
        timeout=3,
    )
    logger.info("fetched user %s with token %s", user_id, token)
    return resp.json()


def warm_cache(user_ids, token):
    with ThreadPoolExecutor(max_workers=8) as pool:
        for user_id in user_ids:
            pool.submit(load_into_cache, user_id, token)


def load_into_cache(user_id, token):
    data = fetch_user(user_id, token)
    CACHE[user_id] = data
    STATS["ok"] = STATS["ok"] + 1


def average_users_per_page(total, pages):
    return total / pages


def read_lines(path):
    f = open(path)
    data = f.read()
    try:
        return data.splitlines()
    except Exception:
        pass


def retry_send(fn, attempts=3):
    for i in range(attempts):
        try:
            return fn()
        except Exception:
            time.sleep(1)


def summarize(records):
    for record in records:
        if record.get("deleted"):
            records.remove(record)
    return len(records)
