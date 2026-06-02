---
name: excel-phase-workflow-tracker
description: 构建/改进"按阶段流转"的 Excel 追踪表时使用——需求SOP、任务管理、Bug 流转、流程监控、OKR 推进等。覆盖"填而不覆盖"自动日期、COUNTIFS 仪表盘、阶段→进度映射表、xlsx 结构检查、Office Scripts 自动化等核心模式。触发信号：用户给出"阶段列表 + 每阶段要填日期/字段 + 想要顶部仪表盘"的需求。
---

# Excel 阶段流转追踪表

## 何时使用

构建/修改任何"需求/任务按阶段推进"的 Excel 模板时。典型场景：
- 需求SOP追踪（需求评审→技术评审→用例→Showcase→测试→上线→归档）
- Bug 流转表（新建→确认→修复中→验证→关闭）
- Sprint/任务管理（待办→进行中→已交付→归档）
- OKR 推进、流程监控（任意阶段+日期+状态机）

## 五大核心模式

### 1. 阶段→日期列的"填而不覆盖"逻辑

**问题**：每个阶段对应一个日期列，希望切到某阶段时自动填"今天"，但旧阶段日期不能丢。

**解法**：用 Office Scripts 监听"当前阶段"列变化，只在对应日期列为空时填入。**纯 Excel 公式做不到"写一次就不动"**。

```javascript
// 阶段名 → 日期列字母的映射
const stageToDateCol: Record<string, string> = {
  "测试环境1": "U",
  "测试环境2": "V",
  "测试环境3": "W",
  "Showcase": "S",
};

for (let row = startRow; row <= endRow; row++) {
  const stageValue = sheet.getRange(`G${row}`).getValue() as string;
  if (!stageValue) continue;            // 空行跳过
  const col = stageToDateCol[stageValue];
  if (!col) continue;
  const cell = sheet.getRange(`${col}${row}`);
  if (cell.getValue() === "" || cell.getValue() === null) {
    cell.setValue(todaySerial);
    cell.setNumberFormatLocal("yyyy-mm-dd");
  }
}
```

**关键原则**：先读后写，只填空，已有值一律不动。

完整脚本见 `scripts/auto-fill-stages.ts`。

### 2. 仪表盘用 COUNTIFS 实时算（不要手填数字）

顶部"进行���/逾期/风险"等数字必须用公式从明细表动态算，否则数字会脱钩。

```excel
=COUNTIFS($B$18:$B$117,"<>",$AB$18:$AB$117,$B$123)   // 进行中
=COUNTIFS($AA$18:$AA$117,$C$125)                      // 逾期
=COUNTIFS($B$18:$B$117,"<>",$E$18:$E$117,">="&TODAY(),$E$18:$E$117,"<="&TODAY()+7,$F$18:$F$117,"",$AB$18:$AB$117,"<>"&$B$125)  // 7天内上线
```

**反模式**：在仪表盘单元格里直接打一个数字 3，看着没问题，等明细加到第 6 条时仪表盘还是 3。

### 3. 阶段→进度映射表 + INDEX/MATCH 自动算完成率

在表格底部放一张"阶段→进度数值"的隐藏/半隐藏映射表：

| 阶段全称 | 阶段短名 | 进度 |
|---|---|---|
| 需求评审 | 需求评审 | 0.1 |
| 技术方案评审 | 技术评审 | 0.25 |
| 测试文档/Showcase文档编写 | 文档编写 | 0.4 |
| 测试用例评审 | 用例评审 | 0.55 |
| Showcase | Showcase | 0.7 |
| 测试环境1 | 测试环境1 | 0.78 |
| 测试环境2 | 测试环境2 | 0.86 |
| 测试环境3 | 测试环境3 | 0.94 |
| 已上线待归档 | 待归档 | 1 |
| 已归档 | 已归档 | 1 |

完成率列用 INDEX/MATCH 自动查：
```excel
=IFERROR(INDEX($G$123:$G$132,MATCH($G18,$E$123:$E$132,0)),0)
```

**关键陷阱**：映射表的查询字段（这里是 E123:E132）和 G 列的"当前阶段"字面值必须**严格一致**。改一个标点 MATCH 就会静默失败，UI 看着没事但 X 列突然全是 0。

### 4. 状态机的级联判定

不要把状态做成多列互斥字段，用单列"实际值"+级联 IF 自动判：

```excel
=IF(已归档, "", 
  IF(实际上线<>"", "已上线",
    IF(计划上线="", "",
      IF(计划上线<TODAY(), "逾期",
        IF(计划上线-TODAY()<=3, "3天内上线", "正常")))))
```

**级联顺序**：终态优先（已归档 > 已上线）> 风险优先（逾期 > 临近）> 默认（正常）。逻辑写错顺序会出现"已归档但显示逾期"这种悖论。

### 5. 下拉校验 + 条件格式

- **当前阶段列**：`数据验证 → 列表`（10 个阶段固定）
- **状态列**：6 个状态固定
- **优先级列**：P0/P1/P2
- **条件格式**：按内容自动配色（不能光靠眼睛认）——配合 `<x:conditionalFormatting>` 的 `containsText` 规则批量设

## 验证与排查

### 读 xlsx XML 看真实结构

不要相信 Excel UI 显示的"看似简单"，xlsx 内部可能塞了几十个条件格式规则和数据验证。直接解压看 XML：

```bash
unzip -p file.xlsx xl/worksheets/sheet1.xml | head -300
```

可以清楚看到：
- 列宽定义 `<x:cols>`
- 合并单元格 `<x:mergeCells>`
- 条件格式 `<x:conditionalFormatting>` 的 `sqref` 和 `dxfId`
- 数据验证 `<x:dataValidations>`
- 公式 `<x:f>` 和值 `<x:v>`

详见 `references/xlsx-structure-inspection.md`。

## 常见陷阱

1. **明细区空白槽太多**：模板默认 100 行空行 + 5 条样本 = 90% 空白。等真用上 15+ 条时仪表盘和明细比例会失衡
2. **短名表和全名表不一致**：INDEX/MATCH 会静默失败，UI 看着没事但 X 列突然全是 0
3. **"自动填日期"≠"自动覆盖"**：要"填而不覆盖"必须用 Office Scripts 或 VBA，纯公式做不到
4. **手填数字会脱钩**：仪表盘数字必须公式化（COUNTIFS / SUMPRODUCT）
5. **"单页版"承诺撑不住**：30+ 列在 1080p 屏幕上一定会横滚。考虑核心 10 列 + 详情页拆分
6. **example.com 占位链接**：demo 阶段合理，但真给同事看时第一反应是"链接打不开"，要清掉或换真实链接
7. **级联 IF 顺序写反**：会出现"已归档但显示逾期"这种悖论。终态永远先判
8. **公式断引用**：用 `$B$18:$B$117` 这种**绝对引用**包住明细范围，行数扩到 200 时只改一个数字就行，不要全表手改

## 配套资源

- `references/xlsx-structure-inspection.md` — 用 unzip 读 xlsx 内部 XML 结构、常见标签含义、排查公式断引用的方法
- `scripts/auto-fill-stages.ts` — Office Scripts 监听阶段变化、自动填日期的完整实现（fill-if-empty 模式）
- `scripts/inspect-xlsx.sh` — 一键检查 xlsx 公式、条件格式、数据验证的 shell 脚本
