def read_note(n):
    try:
        with open(n, "r", encoding="utf-8") as f:
            content = f.read()
            print(content[:50])
    except FileNotFoundError:
        print("文件未找到，请检查路径")
    except UnicodeDecodeError:
        print("文件编码异常")


