# DOCX Thesis Manipulation Workflow

Reference guide for programmatically manipulating DOCX files for thesis/dissertation expansion and revision.

## Common Tasks

### 1. Count Chinese Characters in DOCX

```python
from docx import Document
import re

doc = Document('thesis.docx')
total_cn = 0
for para in doc.paragraphs:
    cn_chars = len(re.findall(r'[\u4e00-\u9fff]', para.text))
    total_cn += cn_chars
print(f"Total Chinese characters: {total_cn}")
```

### 2. Count by Chapter

```python
chapters = {}
current_chap = None

for para in doc.paragraphs:
    text = para.text.strip()
    if text.startswith('第') and '章' in text:
        if '一' in text: current_chap = 'Ch1'
        elif '二' in text: current_chap = 'Ch2'
        elif '三' in text: current_chap = 'Ch3'
        elif '四' in text: current_chap = 'Ch4'
        chapters[current_chap] = 0
    
    if current_chap:
        chapters[current_chap] += len(re.findall(r'[\u4e00-\u9fff]', para.text))
```

### 3. Insert Content at Specific Section

```python
# Find section position
insert_idx = None
for i, para in enumerate(doc.paragraphs):
    if '2.4.1' in para.text and '关键词' in para.text:
        insert_idx = i
        para.text = '2.4.1 新标题'
        break

# Find end of section
end_idx = None
for j in range(insert_idx + 1, len(doc.paragraphs)):
    if doc.paragraphs[j].text.strip().startswith('2.4.2'):
        end_idx = j
        break

# Insert new paragraphs after the section header
new_content = [
    ('小标题', True),  # (text, is_bold)
    ('正文内容...', False),
]

for text, bold in reversed(new_content):
    p = doc.paragraphs[insert_idx]._element
    new_p = doc.add_paragraph(text)
    if bold:
        new_p.runs[0].bold = True
    p.addnext(new_p._element)
```

### 4. Safe Section Expansion Pattern

When expanding a thesis section programmatically:

1. **Always work on a copy**: Save to `_enhanced.docx` or `_v2.docx`
2. **Locate by section number + keyword**: Don't rely on exact text match
3. **Find section boundaries**: Look for next section number or figure caption
4. **Insert from bottom up**: Use `reversed()` to maintain order
5. **Verify character count**: Compare before/after totals

## Pitfalls

- **Paragraph index shifts**: After insertion, indices change - calculate upfront
- **Style loss**: New paragraphs may lose formatting - apply styles explicitly
- **Encoding issues**: Chinese text must be UTF-8 in Python source
- **Element removal**: Deleting paragraphs changes document structure unexpectedly

## Dependencies

```bash
pip install python-docx
```
