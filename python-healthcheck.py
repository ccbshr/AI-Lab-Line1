"""Python 安装体检脚本：验证 stdlib 可导入性与关键能力。"""
import importlib
import sys

mods = [
    "ssl", "sqlite3", "ctypes", "zlib", "lzma", "bz2", "hashlib", "decimal",
    "unicodedata", "select", "socket", "email", "json", "uuid", "zoneinfo",
    "_decimal", "_queue", "multiprocessing", "venv", "ensurepip",
    "urllib.request", "http.client", "xml.etree.ElementTree", "csv",
    "tkinter", "idlelib", "curses",
]
bad = []
for m in mods:
    try:
        importlib.import_module(m)
    except Exception as e:  # noqa: BLE001
        bad.append(f"{m}: {type(e).__name__}: {str(e)[:70]}")

print("Python  :", sys.version.split()[0])
print("exe     :", sys.executable)
print("失败模块:", "\n          ".join(bad) if bad else "无")

import ssl  # noqa: E402
print("OpenSSL :", ssl.OPENSSL_VERSION)
import sqlite3  # noqa: E402
print("SQLite  :", sqlite3.sqlite_version)
