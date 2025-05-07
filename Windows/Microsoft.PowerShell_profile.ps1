if ($env:TERM_PROGRAM -ne 'vscode') {
    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'Continue'
}

$Env:_CE_M = $null
$Env:_CE_CONDA = $null
# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
Import-Module -Name Terminal-Icons
Import-Module PSReadLine        


#Module
Set-PSReadLineOption -PredictionSource History
oh-my-posh init pwsh --config C:\Users\tontide1\scoop\apps\oh-my-posh\24.5.1\themes\tontide1.omp.json | Invoke-Expression

# Custom utilities
function Update-Profile { 
    & $PROFILE.CurrentUserAllHosts
    Write-Host "Profile reloaded!" -f green 
}

function open {
    param(
        [string]$path = "."
    )
    Start-Process explorer $path
}


Set-Alias -Name up -Value Update-Profile

# Security settings
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -AddToHistoryHandler {
    param($command)
    return $command -notmatch '^(ssh|mstsc|password)\s+'
}

# Smart tab completion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Git integration
if (Get-Command git -ErrorAction SilentlyContinue) {
    $env:GIT_ASKPASS = ""
    $env:GIT_TERMINAL_PROMPT = 1
}
