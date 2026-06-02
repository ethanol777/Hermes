/**
 * Office Scripts: 阶段流转时自动填日期（fill-if-empty 模式）
 *
 * 用法：
 * 1. 打开 Excel → "自动化" → 新建脚本
 * 2. 整段粘贴
 * 3. 手动运行，或绑到 Power Automate 触发器
 *
 * 行为：
 * - 读 G 列（当前阶段）
 * - 阶段名匹配到映射表时，对应日期列如果为空就填今天
 * - 已有日期一律不动（保留历史轨迹）
 *
 * ⚠️ 修改本文件前请读 SKILL.md 的"填而不覆盖"原则。
 */

function main(workbook: ExcelScript.Workbook) {
  const sheet = workbook.getActiveWorksheet();
  const startRow = 18;  // ← 改成你明细表的起始行
  const endRow = 117;   // ← 改成你明细表的结束行

  // === 阶段名 → 日期列字母的映射 ===
  // 根据实际表结构调整
  const stageToDateCol: Record<string, string> = {
    "需求评审": "K",
    "技术方案评审": "N",
    "测试用例评审": "Q",
    "Showcase": "S",
    "测试环境1": "U",
    "测试环境2": "V",
    "测试环境3": "W",
  };

  // 计算今日序列日期（Excel 1900 系统）
  const today = new Date();
  const todaySerial = Math.floor(
    (today.getTime() - Date.UTC(1899, 11, 30)) / 86400000
  );

  let filledCount = 0;
  let skippedCount = 0;

  for (let row = startRow; row <= endRow; row++) {
    const stageCell = sheet.getRange(`G${row}`);
    const stageValue = stageCell.getValue() as string;

    if (!stageValue) continue;  // 空行跳过

    const col = stageToDateCol[stageValue];
    if (!col) continue;  // 没在映射里，跳过（比如"已归档"不触发）

    const dateCell = sheet.getRange(`${col}${row}`);
    const currentValue = dateCell.getValue();

    // 只填空，不覆盖
    if (currentValue === "" || currentValue === null) {
      dateCell.setValue(todaySerial);
      dateCell.setNumberFormatLocal("yyyy-mm-dd");
      filledCount++;
    } else {
      skippedCount++;
    }
  }

  // 调试时取消注释
  // console.log(`Filled: ${filledCount}, Skipped: ${skippedCount}`);
}
