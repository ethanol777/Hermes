# xlsx 结构检查手册

## 为什么需要

Excel UI 显示的信息有限。xlsx 内部是一个 ZIP 包，里面是结构化 XML。**当表出现"看着对、数值不对"时，UI 是沉默的，只有 XML 才会说实话。**

## 一键检查

```bash
# 看主工作表
unzip -p file.xlsx xl/worksheets/sheet1.xml | head -300

# 看工作簿所有 sheet 列表
unzip -p file.xlsx xl/workbook.xml

# 看样式定义
unzip -p file.xlsx xl/styles.xml

# 看共享字符串
unzip -p file.xlsx xl/sharedStrings.xml
```

完整脚本见 `scripts/inspect-xlsx.sh`，可一次性输出所有 sheet 名 + 公式数 + 条件格式规则数 + 数据验证数。

## 关键 XML 标签速查

| 标签 | 含义 |
|---|---|
| `<x:cols>` | 列宽定义（min/max/width/customWidth） |
| `<x:mergeCells>` | 合并单元格（ref="A1:AD1" 这种） |
| `<x:row ht="48" customHeight="1">` | 行高（48 单位 = 32px） |
| `<x:c r="A1" s="4" t="str">` | 单元格，s=样式索引，t=类型（str/n/b） |
| `<x:f>FORMULA</x:f>` | 公式 |
| `<x:v>VALUE</x:v>` | 计算结果或静态值 |
| `<x:conditionalFormatting sqref="A1:A10">` | 条件格式作用范围 |
| `<x:cfRule type="containsText" dxfId="0">` | 单条规则（dxfId 对应 styles.xml 里的样式） |
| `<x:dataValidations count="3">` | 数据验证集合 |
| `<x:dataValidation type="list">` | 下拉列表（formula1 写可选项，逗号分隔） |

## 常见症状对应排查

| 症状 | 在 XML 里看什么 |
|---|---|
| 公式返回 0 但不该是 0 | 看 `<x:f>` 里的引用范围，`$B$18:$B$117` 这种是否还匹配实际数据行 |
| 条件格式不生效 | 看 `<x:cfRule>` 的 `operator="containsText"` 和 `text="..."` 字符串是否和实际值严格一致 |
| 下拉框选项错了 | 看 `<x:dataValidation>` 的 `<x:formula1>` 内容，注意是 `"P0,P1,P2"` 还是直接文本 |
| 短名表和全名表匹配不上 | 用 `unzip -p` grep 两次确认两份字符串字面一致 |
| 完成率 INDEX/MATCH 静默失败 | `IFERROR(...,0)` 会吞掉所有错误，看着是 0 实际是 #N/A |

## 单元格类型 `t` 字段

- `t="str"` — 字符串（公式结果或静态文本）
- `t="n"` — 数字（默认）
- `t="b"` — 布尔
- `t="inlineStr"` — 内联字符串（不查 sharedStrings 表）

日期在 xlsx 里存为**序列号**（自 1900-01-01 起的天数），不是 ISO 字符串。要在脚本里生成 Excel 日期：

```javascript
const today = new Date();
const todaySerial = Math.floor(
  (today.getTime() - Date.UTC(1899, 11, 30)) / 86400000
);
```

## 实操案例：诊断"完成率 = 0"

1. 打开 xlsx → 看 X 列（完成率）
2. 全部是 0，但 G 列（当前阶段）有值
3. unzip 找 X18 → 看 `<x:f>IFERROR(INDEX($G$123:$G$132,MATCH($G18,$E$123:$E$132,0)),0)</x:f>`
4. unzip 找 E123:E132（查询字段）和 G18（实际值）
5. 对比字符串：通常会发现 `Showcase` vs `Showcase `（多了空格）或者 `已上线待归档` vs `已上线待归档 `（全半角混用）
6. 改 E123:E132 让它和 G 列字面完全一致，保存

**这步是手工活，没有捷径**。XML 不会撒谎，但要你逐字对比。
