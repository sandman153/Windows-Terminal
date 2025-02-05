# Install Required PowerShell Modules

param (
    [switch]$DebugMode
)

# Prevent infinite loop by ensuring this script does not call itself recursively
if ($global:ModulesAlreadyInstalled) {
    Write-Host "✔ PowerShell modules are already installed. Skipping..." -ForegroundColor Green
    return
}
$global:ModulesAlreadyInstalled = $true

# List of modules to install
$modules = @(
    "PSReadLine",
    "Terminal-Icons",
    "posh-git"
)

# Install each module if not already installed
foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "🔹 Installing $module..." -ForegroundColor Yellow
        Install-Module -Name $module -Scope CurrentUser -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "✔ $module is already installed." -ForegroundColor Green
    }
}

Write-Host "✔ All required PowerShell modules installed successfully!" -ForegroundColor Green
