# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

#Module
Import-Module -Name Terminal-Icons

oh-my-posh init pwsh --config C:\Users\tontide1\scoop\apps\oh-my-posh\19.8.3\themes\tontide1.omp.json | Invoke-Expression

# Alias
Set-Alias j 'C:\Users\tontide1\AppData\Local\Programs\Python\Python311\Scripts\jupyter-notebook.exe'
Set-Alias subl 'C:\Program Files\Sublime Text\subl.exe'
Set-Alias ll ls
Set-Alias my Set-MyData

# Utilities
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
function Set-MyData {
    Set-Location 'C:\Users\tontide1\Desktop\Data'
}
