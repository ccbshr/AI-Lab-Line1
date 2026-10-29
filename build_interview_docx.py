"""生成《生涯人物访谈提纲.docx》。

结构完全对齐原表（手机截图那份）：标题、字数提示、采访人行、三大部分。
事实性信息用【】占位，正文为可改用的范文。
"""

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.shared import Pt, Cm, RGBColor
from docx.oxml import OxmlElement

BODY_FONT = "宋体"
HEAD_FONT = "黑体"


def style_run(run, name=BODY_FONT, size=12, bold=False, color=None, italic=False):
    run.font.name = name
    run.font.size = Pt(size)
    run.bold = bold
    run.italic = italic
    if color is not None:
        run.font.color.rgb = color
    rpr = run._element.get_or_add_rPr()
    rfonts = rpr.find(qn("w:rFonts"))
    if rfonts is None:
        rfonts = OxmlElement("w:rFonts")
        rpr.append(rfonts)
    rfonts.set(qn("w:eastAsia"), name)
    rfonts.set(qn("w:ascii"), name)
    rfonts.set(qn("w:hAnsi"), name)


def add_para(doc, text="", *, name=BODY_FONT, size=12, bold=False, color=None,
             align=None, indent_chars=0, space_before=0, space_after=6, line=1.5):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    if align is not None:
        p.alignment = align
    if indent_chars:
        pf.first_line_indent = Pt(size * indent_chars)
    pf.space_before = Pt(space_before)
    pf.space_after = Pt(space_after)
    pf.line_spacing = line
    if text:
        style_run(p.add_run(text), name=name, size=size, bold=bold, color=color)
    return p


def add_label_and_body(doc, label, body):
    """加粗小标题 + 正文（正文首行缩进两字符）。"""
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.space_before = Pt(6)
    pf.space_after = Pt(2)
    pf.line_spacing = 1.5
    style_run(p.add_run(label), name=BODY_FONT, size=12, bold=True)
    add_para(doc, body, indent_chars=2, space_before=0, space_after=8)


doc = Document()

# 页面设置：A4 + 常规页边距
sec = doc.sections[0]
sec.page_width = Cm(21.0)
sec.page_height = Cm(29.7)
sec.top_margin = Cm(2.54)
sec.bottom_margin = Cm(2.54)
sec.left_margin = Cm(3.17)
sec.right_margin = Cm(3.17)

# 默认字体
normal = doc.styles["Normal"]
normal.font.name = BODY_FONT
normal.font.size = Pt(12)
normal.element.rPr.rFonts.set(qn("w:eastAsia"), BODY_FONT)

# ===== 标题 =====
add_para(doc, "生涯人物访谈提纲", name=HEAD_FONT, size=22, bold=True,
         align=WD_ALIGN_PARAGRAPH.CENTER, space_before=12, space_after=4)
add_para(doc, "（至少 1000 字）", size=10.5, color=RGBColor(0xC0, 0x00, 0x00),
         align=WD_ALIGN_PARAGRAPH.CENTER, space_after=18)

# ===== 采访人信息 =====
add_para(doc, "采访人姓名：【　　　】　　班级：【　　　】　　学号：【　　　　】", space_after=4)
add_para(doc, "采访时间：【2026 年 　 月 　 日】", space_after=4)
add_para(doc, "采访方式：【线下面对面 / 电话 / 视频】", space_after=14)

# ===== 一 =====
add_para(doc, "一、被采访人基本信息", name=HEAD_FONT, size=14, bold=True,
         space_before=6, space_after=8)
add_para(doc, "姓名：【　　　】　　联系方式：【　　　　】", space_after=4)
add_para(doc, "目前就读院校/工作单位：【　　　　　　】", space_after=4)
add_para(doc, "所属类别：", space_after=2)

doc.add_paragraph().paragraph_format.space_after = Pt(0)
categories = [
    ("□", "毕业生学生：升学名校/跨专业升学/从普通成绩逆袭/非对口专业就业/进入名企核心岗位等", False),
    ("□", "在校学生：担任主要学生干部/科技竞赛获奖/获各类校级荣誉表现突出/勤工助学表现突出/文体活动突出等", False),
    ("☑", "在职人员：学校老师及工作人员/父母兄弟姐妹亲友/企业工作人员等", True),
]
for mark, text, chosen in categories:
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.left_indent = Pt(24)
    pf.space_after = Pt(4)
    pf.line_spacing = 1.5
    style_run(p.add_run(f"{mark} {text}"), size=12, bold=chosen)

# ===== 二 =====
add_para(doc, "二、Ta 的就业故事/经验分享", name=HEAD_FONT, size=14, bold=True,
         space_before=14, space_after=8)

add_label_and_body(
    doc,
    "Ta 是如何确定目标的：（简述职业规划过程）",
    "Ta 说自己的目标并不是一开始就想清楚的，而是“试”出来的。本科前两年，Ta 对“数据分析”只有一个模糊印象，"
    "直到大二参加数学建模竞赛，才第一次体会到“用数据把一个结论讲清楚”带来的成就感。大三上学期，Ta 去一家小型电商公司做运营数据分析实习，"
    "每天的工作是拉数据、做看板、给运营提建议——正是在这种“每周都要交东西”的高频反馈里，Ta 意识到自己更喜欢贴近业务、能直接影响决策的方向。"
    "大三下学期，Ta 把目标从“考研”调整为“先就业、在工作中补短板”，并据此把精力集中到 SQL、Python 和业务指标体系上。"
    "入职两年后，Ta 的目标又迭代了一次：从“能独立完成需求”变成“能主导一个数据产品的落地”。"
    "Ta 的体会是，职业目标不是一次选定就锁死的，而是每半年复盘一次、依据真实反馈微调。",
)

add_label_and_body(
    doc,
    "Ta 为实现目标做了哪些准备：（列举关键努力，如实习、竞赛、学习等）",
    "在具体准备上，Ta 归纳了四条主线。第一是补基础：把统计学、SQL 和 Python 当作“每天都要用”的工具，"
    "而不是“考试科目”，遇到不会的就当场查文档、当场写一段代码验证。第二是参加竞赛：数学建模和一次数据竞赛让 Ta 学会了在时间压力下拆解问题，"
    "以及怎么写一份让评委看得懂的报告。第三是实习试错：Ta 一共做过两段实习，第一段在小公司，什么都要自己扛，练的是全流程；"
    "第二段在大公司，练的是工程规范和跨部门协作——“两段加起来才知道自己缺什么”。第四是有意识地沉淀作品：每做完一个项目，"
    "Ta 都会写一份复盘文档并放进自己的代码仓库，记录问题、可选方案和最终效果。Ta 强调，很多同学“学过但说不出做过什么”，"
    "而面试时真正能打动人的，往往是这种可展示、可追问的产出。",
)

add_label_and_body(
    doc,
    "Ta 的成功经验和建议：（例如：尽早实习试错、学好 XX 软件、主动联系导师参与课题等）",
    "Ta 给了五条建议。一是尽早实习，最好在大二暑假就开始，因为“试错的成本只会随时间上涨”；二是有产出意识，"
    "把课程作业也当成作品来打磨，能上线、能量化、能复盘；三是主动出击，别等机会来找你——Ta 的第一段实习就是主动给一家公司的业务负责人发邮件争取来的；"
    "四是补齐那些“通用但没人教”的工具：SQL、Git、Linux 基础命令，以及把表格工具用得足够熟练；五是学会把成果讲清楚，"
    "面试前反复问自己三个问题：为什么做、怎么做、效果如何量化。最后 Ta 补了一句：“不要用‘忙’来掩盖‘没有方向’，"
    "每周留半小时复盘，比多刷两小时题更有用。”",
)

# 一句话寄语
p = doc.add_paragraph()
pf = p.paragraph_format
pf.space_before = Pt(8)
pf.space_after = Pt(2)
pf.line_spacing = 1.5
style_run(p.add_run("Ta 的一句话寄语"), size=12, bold=True)

p = doc.add_paragraph()
pf = p.paragraph_format
pf.left_indent = Pt(24)
pf.space_after = Pt(2)
pf.line_spacing = 1.5
style_run(p.add_run("“把每一次‘不得不做’的任务，都当成一件可以留下的作品去完成。”"), size=12, italic=True)

add_para(doc,
         "——这句话最触动我的地方在于：它把“被动完成任务”和“主动积累作品”区分开了，而只有后者才是别人看得见、也问得下去的能力证明。",
         indent_chars=2, space_after=10)

# ===== 三 =====
add_para(doc, "三、访谈之后，我的感悟", name=HEAD_FONT, size=14, bold=True,
         space_before=10, space_after=8)

add_para(doc,
         "这次访谈给我带来最大的收获，是三个认知上的转变。第一，目标不是“想”出来的，而是“试”出来的。"
         "我原来总觉得要先想清楚方向再行动，但 Ta 的经历说明，恰恰是那些低成本的小行动（一次竞赛、一段实习）才能带来真实的信息，"
         "让人有机会修正方向。第二，能力的证据正在从“成绩单”转向“作品和指标”。分数只能证明你会考试，"
         "而一段实习、一个仓库、一份复盘文档，才能证明你能解决真实问题。第三，信息差要靠主动获取。"
         "Ta 提到的“主动发邮件争取实习”让我意识到，很多机会并不是没有，而是没有被主动问出来。",
         indent_chars=2, space_after=8)

add_para(doc,
         "落实到我自己身上，我打算做三件事：一是这学期把 SQL 和 Python 的基础打牢，并完成至少一个端到端的小项目"
         "（从取数、分析到出报告）；二是在寒假前投出第一份实习申请，哪怕是小公司，先获得真实反馈；"
         "三是建立自己的复盘习惯，每周写一段记录，把做过的事沉淀成可展示的材料。"
         "这次访谈让我明白，职业规划不是一个需要一次性想明白的大问题，而是一连串可以被执行、被验证、被修正的小决定。",
         indent_chars=2, space_after=8)

out = "生涯人物访谈提纲.docx"
doc.save(out)

# 统计字数（中文字符 + 英文单词近似）
import re
text = "\n".join(p.text for p in doc.paragraphs)
cn = len(re.findall(r"[\u4e00-\u9fff]", text))
print(f"saved: {out}")
print(f"总字符数: {len(text)}")
print(f"中文字数: {cn}")
print(f"段落数: {len(doc.paragraphs)}")
