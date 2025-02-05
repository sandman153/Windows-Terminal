# Setup PowerShell Profile for Oh My Posh (Local Profile + Git Sync)

param (
    [string]$GitHubUsername = "yourusername",
    [string]$ComputerName = $env:COMPUTERNAME,
    [switch]$DebugMode
)

# Function to log messages with timestamps
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

# Debug Mode Logging
if ($DebugMode) { Write-Log "Debug Mode Enabled" "DEBUG" }

# Define profile paths for multi-device setup (Local Only, No OneDrive Sync)
$gitProfilePath = "E:\Development\Windows-Terminal\PowerShell_profile.ps1"
$localProfilePath = "E:\Development\Windows-Terminal\PowerShell_profile.ps1"
$destinationProfile = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$oneDriveProfile = "F:\OneDrive - Personal\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# Ensure all devices use a local profile and sync via Git
Write-Log "Using local profile for PowerShell. Sync handled via Git." "INFO"

# Debug: Show current profile path
if ($DebugMode) { Write-Log "Current Profile Path: $PROFILE" "DEBUG" }

# Ensure the directory exists before creating the profile file
$localProfileDir = Split-Path -Path $localProfilePath -Parent
if (-not (Test-Path $localProfileDir)) {
    Write-Log "Creating missing directory: $localProfileDir" "WARN"
    New-Item -ItemType Directory -Path $localProfileDir -Force | Out-Null
}

# Ensure PowerShell modules are installed and configured
$modules = @("PSReadLine", "Terminal-Icons", "z", "PSFzf", "posh-git", "Oh-My-Posh")
foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Log "Installing missing module: $module" "INFO"
        Install-Module -Name $module -Scope CurrentUser -Force -SkipPublisherCheck
    } else {
        Write-Log "Module already installed: $module" "SUCCESS"
    }
}

# Special handling for PSFzf (Requires fzf binary in PATH)
if ($modules -contains "PSFzf") {
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Log "⚠️ fzf binary not found in PATH. Skipping PSFzf import." "WARN"
    } else {
        Import-Module PSFzf -ErrorAction SilentlyContinue
    }
}

# Import necessary modules after installation
foreach ($module in $modules) {
    if ($module -ne "PSFzf") {
        Import-Module -Name $module -ErrorAction SilentlyContinue
    }
}

# Backup existing profile if it exists
if (Test-Path $destinationProfile) {
    $backupPath = "$destinationProfile.bak"
    Copy-Item -Path $destinationProfile -Destination $backupPath -Force
    Write-Log "Backup created: $backupPath" "INFO"
}

# Load existing profile content to preserve user settings
$existingProfileContent = if (Test-Path $destinationProfile) {
    Get-Content $destinationProfile -Raw -ErrorAction SilentlyContinue
} else {
    ""
}

# Ensure Oh My Posh initialization is included only once
if ($existingProfileContent -notmatch "oh-my-posh --init") {
    Write-Log "Adding Oh My Posh to PowerShell profile for auto-loading." "INFO"
    $ohMyPoshConfig = @"

# Auto-load Oh My Posh theme on every terminal launch
if (Test-Path "E:\Development\Windows-Terminal\20211104-sarath-terminal.json") {
    oh-my-posh --init --shell pwsh --config "E:\Development\Windows-Terminal\20211104-sarath-terminal.json" | Invoke-Expression
} else {
    Write-Log "Theme file not found. Skipping theme application." "WARN"
}
"@
    $newProfileContent = "$existingProfileContent`n$ohMyPoshConfig"
    Set-Content -Path $destinationProfile -Value $newProfileContent -Force
} else {
    Write-Log "Oh My Posh is already configured in profile. Skipping modification." "INFO"
}

# Ensure profile is copied to OneDrive if it exists
if (Test-Path "F:\OneDrive - Personal\OneDrive\Documents\PowerShell") {
    if (-not (Test-Path $oneDriveProfile) -or (Get-Item $localProfilePath).LastWriteTime -gt (Get-Item $oneDriveProfile).LastWriteTime) {
        Write-Log "Copying updated profile to OneDrive." "INFO"
        Copy-Item -Path $localProfilePath -Destination $oneDriveProfile -Force
    } else {
        Write-Log "OneDrive profile is up-to-date. Skipping copy." "INFO"
    }
} else {
    Write-Log "OneDrive profile directory not found. Skipping sync." "WARN"
}

# Set PowerShell Execution Policy to allow profile execution
Write-Log "Ensuring PowerShell execution policy allows profile loading." "INFO"
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Optimize loading: Copy only if source file is newer than the destination
if (Test-Path $destinationProfile) {
    $sourceLastWrite = (Get-Item $localProfilePath).LastWriteTime
    $destLastWrite = (Get-Item $destinationProfile).LastWriteTime
    if ($sourceLastWrite -gt $destLastWrite) {
        Write-Log "Source profile is newer. Copying to destination..." "INFO"
        Copy-Item -Path $localProfilePath -Destination $destinationProfile -Force
    } else {
        Write-Log "Destination profile is up-to-date. Skipping copy." "INFO"
    }
} else {
    Write-Log "Destination profile does not exist. Copying..." "INFO"
    Copy-Item -Path $localProfilePath -Destination $destinationProfile -Force
}

# Debug: Confirm profile copy
if ($DebugMode) {
    Write-Log "Profile successfully copied to: $destinationProfile" "DEBUG"
}

# Ensure profile loads on startup
Write-Log "Forcing profile reload..." "INFO"
. $destinationProfile

Write-Log "PowerShell Profile loaded successfully!" "SUCCESS"
