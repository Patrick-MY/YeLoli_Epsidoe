param(
    [string]$Root = (Resolve-Path ".").Path
)

$ErrorActionPreference = "Stop"

$masterPath = Join-Path $Root "项目进度总表.md"
$startMarker = "<!-- PROJECT_PROGRESS_AUTO_START -->"
$endMarker = "<!-- PROJECT_PROGRESS_AUTO_END -->"

if (-not (Test-Path -LiteralPath $masterPath)) {
    throw "未找到总表：$masterPath"
}

function Get-RelativePathText {
    param(
        [string]$Base,
        [string]$Target
    )

    $baseUri = [Uri]((Resolve-Path -LiteralPath $Base).Path.TrimEnd('\') + '\')
    $targetUri = [Uri](Resolve-Path -LiteralPath $Target).Path
    return [Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()).Replace('/', '\')
}

function Get-TopStatus {
    param([hashtable]$Counts)

    if ($Counts.Count -eq 0) {
        return "无记录"
    }

    $ordered = $Counts.GetEnumerator() | Sort-Object @{Expression = "Value"; Descending = $true}, @{Expression = "Name"; Descending = $false}
    $top = $ordered | Select-Object -First 1
    return "$($top.Name) $($top.Value)"
}

function Get-StatusCountsText {
    param([string[]]$Values)

    $counts = @{}
    foreach ($value in $Values) {
        $v = $value.Trim()
        if ($v.Length -eq 0) {
            $v = "空"
        }
        if (-not $counts.ContainsKey($v)) {
            $counts[$v] = 0
        }
        $counts[$v]++
    }

    if ($counts.Count -eq 0) {
        return "无记录"
    }

    return (($counts.GetEnumerator() | Sort-Object @{Expression = "Value"; Descending = $true}, @{Expression = "Name"; Descending = $false} | ForEach-Object { "$($_.Name) $($_.Value)/$($Values.Count)" }) -join "；")
}

function Get-Coverage {
    param([string]$Text)

    $match = [regex]::Match($Text, "范围：(?<range>.+?)(?:\r?\n)")
    if ($match.Success) {
        return $match.Groups["range"].Value.Trim()
    }

    return "未标注"
}

function Get-SegmentCount {
    param([string[]]$Lines)

    $summaryRows = $Lines | Where-Object { $_ -match '^\| [A-Z][0-9]? \|' }
    if ($summaryRows.Count -gt 0) {
        return $summaryRows.Count
    }

    return 0
}

function Get-ShotRows {
    param([string[]]$Lines)

    return $Lines | Where-Object { $_ -match '^\| [A-Z][0-9]?-?[0-9]{2} \|' }
}

$childTables = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter "*镜头制作进度表.md" |
    Where-Object { $_.FullName -ne $masterPath } |
    Sort-Object FullName

$rows = @()
$rows += "| 子表 | 覆盖范围 | 段落 | 镜头 | 生成状态 | 审片状态 | 后期状态 | 修改情况 | 最近更新 |"
$rows += "|---|---|---:|---:|---|---|---|---|---|"

foreach ($table in $childTables) {
    $text = Get-Content -LiteralPath $table.FullName -Raw -Encoding UTF8
    $lines = $text -split "\r?\n"
    $shotRows = Get-ShotRows -Lines $lines

    $generateStatuses = @()
    $reviewStatuses = @()
    $changeNotes = @()
    $postStatuses = @()

    foreach ($row in $shotRows) {
        $cells = $row.Trim('|').Split('|') | ForEach-Object { $_.Trim() }
        if ($cells.Count -ge 9) {
            $generateStatuses += $cells[5]
            $reviewStatuses += $cells[6]
            $changeNotes += $cells[7]
            $postStatuses += $cells[8]
        }
    }

    $relative = Get-RelativePathText -Base $Root -Target $table.FullName
    $linkTarget = $table.FullName.Replace('\', '/')
    $name = $table.Name
    $coverage = Get-Coverage -Text $text
    $segments = Get-SegmentCount -Lines $lines
    $shots = $shotRows.Count
    $updated = $table.LastWriteTime.ToString("yyyy-MM-dd HH:mm")

    $rows += "| [$name]($linkTarget) | $coverage | $segments | $shots | $(Get-StatusCountsText $generateStatuses) | $(Get-StatusCountsText $reviewStatuses) | $(Get-StatusCountsText $postStatuses) | $(Get-StatusCountsText $changeNotes) | $updated |"
}

if ($childTables.Count -eq 0) {
    $rows += "| 暂无子表 | 未标注 | 0 | 0 | 无记录 | 无记录 | 无记录 | 无记录 | - |"
}

$newBlock = $startMarker + "`r`n" + ($rows -join "`r`n") + "`r`n" + $endMarker
$masterText = Get-Content -LiteralPath $masterPath -Raw -Encoding UTF8
$pattern = [regex]::Escape($startMarker) + ".*?" + [regex]::Escape($endMarker)

if (-not [regex]::IsMatch($masterText, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
    throw "总表中未找到自动更新标记。"
}

$updatedText = [regex]::Replace(
    $masterText,
    $pattern,
    [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $newBlock },
    [System.Text.RegularExpressions.RegexOptions]::Singleline
)

Set-Content -LiteralPath $masterPath -Value $updatedText -Encoding UTF8
Write-Host "已更新项目进度总表：$masterPath"
