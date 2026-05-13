$ErrorActionPreference = "SilentlyContinue"

Write-Output "=== D盘空间分析 ==="
Write-Output ""

# 1. Top-level directory sizes
Write-Output "--- 目录空间占用 ---"
Get-ChildItem "D:\" -Directory | ForEach-Object {
    $folder = $_
    $size = (Get-ChildItem $folder.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    if ($size -gt 0) {
        $sizeGB = [math]::Round($size / 1GB, 2)
        Write-Output "$sizeGB GB`t$($folder.Name)"
    }
} | Sort-Object -Descending

Write-Output ""
Write-Output "--- 大文件 (>200MB) 前30个 ---"
Get-ChildItem "D:\" -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 200MB } | Sort-Object Length -Descending | Select-Object -First 30 | ForEach-Object {
    $sizeGB = [math]::Round($_.Length / 1GB, 2)
    $ext = $_.Extension
    Write-Output "$sizeGB GB  $ext  $($_.FullName)"
}

Write-Output ""
Write-Output "--- 缓存/临时目录 ---"
$paths = @(
    @("D:\tmp", "临时文件"),
    @("D:\WUDownloadCache", "Windows Update缓存"),
    @("D:\DeliveryOptimization", "传递优化缓存"),
    @("D:\Search", "搜索索引"),
    @("D:\Config.Msi", "MSI安装残留"),
    @("D:\下载合集", "下载合集"),
    @("D:\MapData", "地图数据")
)
foreach ($p in $paths) {
    if (Test-Path $p[0]) {
        $s = (Get-ChildItem $p[0] -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        $g = [math]::Round($s/1GB, 2)
        Write-Output "$g GB`t$($p[1])`t$($p[0])"
    }
}

Write-Output ""
Write-Output "--- 潜在可清理 (旧安装包/日志/临时文件) ---"
Get-ChildItem "D:\" -Recurse -File -Include "*.log","*.tmp","*.cab","*.msu","*.iso","*.zip","*.rar","*.7z" -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 100MB } | Sort-Object Length -Descending | Select-Object -First 20 | ForEach-Object {
    $sizeGB = [math]::Round($_.Length / 1GB, 2)
    Write-Output "$sizeGB GB  $($_.Extension)  $($_.FullName)"
}
