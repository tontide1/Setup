# 0) Yên lặng + UTF-8
if ($env:TERM_PROGRAM -ne 'vscode') {
    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'Continue'
}
[Console]::InputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($true)

Import-Module -Name Terminal-Icons


# 1) PSReadLine: nhanh & tiện
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -MaximumHistoryCount 300

# (Tùy biến màu PSReadLine – đổi theo ý)
Set-PSReadLineOption -Colors @{
    Command          = '#d4d4d4'
    Parameter        = '#9cdcfe'
    String           = '#ce9178'
    Number           = '#b5cea8'
    Operator         = '#d4d4d4'
    Variable         = '#4fc1ff'
    Type             = '#4ec9b0'
    Comment          = '#6a9955'
    Selection        = '#264f78'
    InlinePrediction = '#808080'
    Emphasis         = '#c586c0'
}

# 2) Tools nhẹ
function open { param([string]$path = "."); Start-Process explorer $path }
function Update-Profile { . $PROFILE; Write-Host "Profile reloaded!" -ForegroundColor Green }
Set-Alias up Update-Profile

# 3) Git info (cực nhẹ, chỉ chạy khi ở repo; có cache 1s)
$script:__gitCache = [ordered]@{ path = ''; ts = Get-Date 0; text = '' }
$env:GIT_OPTIONAL_LOCKS = 0  # giảm va chạm lock
function Get-GitPrompt {
    try {
        $root = (git rev-parse --show-toplevel 2>$null)
        if (-not $root) { return '' }

        $now = Get-Date
        if ($script:__gitCache.path -ne $root -or ($now - $script:__gitCache.ts).TotalSeconds -gt 1) {
            $branch = (git rev-parse --abbrev-ref HEAD 2>$null)
            $status = git status --porcelain 2>$null
            $dirtyMark = if ($status) { ' *' } else { '' }

            # Đếm status chi tiết
            $statusText = ""
            if ($status) {
                $added = ($status | Where-Object { $_ -match '^A' }).Count
                $modified = ($status | Where-Object { $_ -match '^M' }).Count
                $deleted = ($status | Where-Object { $_ -match '^D' }).Count
                $renamed = ($status | Where-Object { $_ -match '^R' }).Count
                $untracked = ($status | Where-Object { $_ -match '^\?\?' }).Count

                if ($added) { $statusText += "+$added " }
                if ($modified) { $statusText += "~$modified " }
                if ($deleted) { $statusText += "-$deleted " }
                if ($renamed) { $statusText += "R$renamed " }
                if ($untracked) { $statusText += "?$untracked " }
                $statusText = $statusText.Trim()
            }

            $script:__gitCache = [ordered]@{
                path = $root
                ts   = $now
                text = " [$branch$dirtyMark $statusText]".Trim()
            }
        }
        return $script:__gitCache.text
    }
    catch { return '' }
}

# 4) Màu & ký hiệu (dễ chỉnh)
$PTheme = [ordered]@{
    Icon   = "🧑‍💻"
    Cwd    = "`e[38;5;39m"   # cyan
    Git    = "`e[38;5;214m"  # orange
    Error  = "`e[38;5;203m"  # red
    Reset  = "`e[0m"
    Symbol = "❯"             # đổi thành ">" nếu thích
}
# Hiển thị dạng: CWD [branch*]
function prompt {
    $last = $LASTEXITCODE
    $cwd = (Get-Location).Path
    $git = Get-GitPrompt

    "$($PTheme.Icon) $($PTheme.Cwd)$cwd$($PTheme.Reset)$($PTheme.Git) $git$($PTheme.Reset)`n$($PTheme.Symbol) "
}

# 5) Phím tắt
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# 6) Git env nhẹ
if (Get-Command git -ErrorAction SilentlyContinue) {
    $env:GIT_ASKPASS = ""
    $env:GIT_TERMINAL_PROMPT = 1
}
# ===== End =====
