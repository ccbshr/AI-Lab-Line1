"""实验：多线程下 dict 计数 `+= 1` 是否丢更新（两个调度档位对比）。

对应笔记：docs/20-代码实验/并发计数丢失.md

设计要点：默认 switchinterval=5ms 时，短任务几乎不会在"读-改-写"窗口内被切走，
所以第一次实验很可能**观测不到**丢失。把 switchinterval 压到 1e-6s 并加大迭代量，
才能把竞态窗口真正暴露出来。

运行：python lost_update.py
"""

import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor

STATS = {"ok": 0}
LOCK = threading.Lock()


def bump_unsafe(n: int) -> None:
    """读-改-写三步，线程切换点落在中间就丢计数。"""
    for _ in range(n):
        STATS["ok"] = STATS["ok"] + 1


def bump_locked(n: int) -> None:
    for _ in range(n):
        with LOCK:
            STATS["ok"] += 1


def run(fn, workers: int, per: int) -> tuple[int, float]:
    STATS["ok"] = 0
    t0 = time.perf_counter()
    with ThreadPoolExecutor(max_workers=workers) as pool:
        list(pool.map(lambda _: fn(per), range(workers)))
    return STATS["ok"], (time.perf_counter() - t0) * 1000


if __name__ == "__main__":
    workers, per = 8, 100_000
    expect = workers * per
    print(f"expect = {expect}  (workers={workers} x per={per})")
    print(f"default switchinterval = {sys.getswitchinterval():g}s")
    print()
    print(f"{'switchinterval':>16} {'group':>8} {'measured':>10} {'lost':>8} {'ms':>7}")

    for label, interval in (("default(5ms)", None), ("1e-6s", 1e-6)):
        if interval is not None:
            sys.setswitchinterval(interval)
        unsafe, t_unsafe = run(bump_unsafe, workers, per)
        locked, t_locked = run(bump_locked, workers, per)
        print(f"{label:>16} {'unsafe':>8} {unsafe:>10} {expect - unsafe:>8} {t_unsafe:>7.0f}")
        print(f"{label:>16} {'locked':>8} {locked:>10} {expect - locked:>8} {t_locked:>7.0f}")

    sys.setswitchinterval(0.005)
    print()
    print("verdict: unsafe<expect under tight scheduling => race exists; locked==expect => fix valid")
