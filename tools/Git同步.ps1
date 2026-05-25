# 《叶罗丽好朋友》Git 同步脚本
# 用途：在 Windows 端执行 git push，规避 Linux VM 挂载文件系统的 git 不稳定问题
# 用法：在项目根目录右键 → "使用 PowerShell 运行"，或在终端执行 .\tools\Git同步.ps1

param(
    [string]$Message = ""
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

Write-Host "=== Git 同步 ===" -ForegroundColor Cyan

# 1. 如果没给 message，自动生成
if (-not $Message) {
    $date = Get-Date -Format "yyyy-MM-dd"
    $Message = "$date 进度同步"
}

# 2. Fetch 远端
Write-Host "Fetching remote..." -ForegroundColor Gray
git fetch origin main

# 3. Rebase（禁止 reset --hard）
Write-Host "Rebasing..." -ForegroundColor Gray
$rebaseResult = git rebase origin/main 2>&1
if ($LASTEXITCODE -ne 0) {
    if ($rebaseResult -match "unstaged changes") {
        Write-Host "有未暂存修改，先 stash..." -ForegroundColor Yellow
        git stash
        git rebase origin/main
        git stash pop
    } elseif ($rebaseResult -match "conflict") {
        Write-Host "有冲突，需要手动解决后运行: git rebase --continue" -ForegroundColor Red
        exit 1
    }
}

# 4. 完整性检查
Write-Host "=== 完整性检查 ===" -ForegroundColor Cyan
$checks = @(
    @{Path="6.待审核内容"; Min=18; Name="待审核内容"},
    @{Path="tools"; Pattern="*.mjs"; Min=2; Name="工具脚本"},
    @{Path="资产设定表.md"; Name="资产设定表"},
    @{Path="PROJECT_PROGRESS.md"; Name="项目进度"}
)

$allOk = $true
foreach ($check in $checks) {
    if ($check.Pattern) {
        $count = @(Get-ChildItem $check.Path -Filter $check.Pattern -ErrorAction SilentlyContinue).Count
    } else {
        $exists = Test-Path $check.Path
        $count = if ($exists) { 1 } else { 0 }
    }
    if ($check.Min -and $count -lt $check.Min) {
        Write-Host "  ✗ $($check.Name): 期望 >=$($check.Min), 实际 $count" -ForegroundColor Red
        $allOk = $false
    } elseif ($check.Min -or $count -gt 0) {
        Write-Host "  ✓ $($check.Name): $count" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $($check.Name): 缺失!" -ForegroundColor Red
        $allOk = $false
    }
}

if (-not $allOk) {
    Write-Host "完整性检查失败，取消 push" -ForegroundColor Red
    exit 1
}

# 5. 提交（如果有改动）
$status = git status --porcelain
if ($status) {
    Write-Host "Committing..." -ForegroundColor Gray
    git add -A
    git commit -m $Message
}

# 6. Push
Write-Host "Pushing..." -ForegroundColor Gray
git push origin main

Write-Host "=== 同步完成 ===" -ForegroundColor Green
Write-Host "远端: https://github.com/Patrick-MY/YeLoli_Episode"
