import re

filename = "README.md"

with open(filename, encoding="utf-8") as f:
    lines = f.readlines()

section = [0] * 6  # 最大6階層まで対応

def get_section_number(level):
    section[level - 1] += 1
    for i in range(level, len(section)):
        section[i] = 0
    return ".".join(str(n) for n in section[:level] if n > 0)

heading_re = re.compile(r"^(#+)\s*(.*)$")

new_lines = []
for line in lines:
    m = heading_re.match(line)
    if m:
        level = len(m.group(1))
        title = re.sub(r"^\d+(\.\d+)*\s*", "", m.group(2))  # 既存番号除去
        number = get_section_number(level)
        new_lines.append(f"{m.group(1)} {number} {title}\n")
    else:
        new_lines.append(line)

with open(filename, "w", encoding="utf-8") as f:
    f.writelines(new_lines)

print("セクション番号の付与が完了しました。")