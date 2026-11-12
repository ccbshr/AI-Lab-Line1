import json
from pathlib import Path
summary=[]
one = Path("notes")
notes = (one.rglob("*.md"))
for note in notes:
    with open(note,"r", encoding="utf-8") as file:
        x=file.read()
        y=len(x)
        print(f"文件{note}字节数为{y}")
    with open(note, "r", encoding="utf-8") as file:
        n = file.readlines()
        lines = len(n)
        print(f"文件{note},行数为{lines}")
    summary.append({
        "文件名": str(note),
        "字节数": str(y),
        "行数": str(lines),
    })
with open("summary.json", "w", encoding="utf-8") as file:
    json.dump(summary,file,ensure_ascii=False,indent=4)
