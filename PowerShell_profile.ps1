# Fix PowerShell Profile for Oh My Posh

# Ensure Oh My Posh is installed
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Host "⚠ Oh My Posh not found. Installing..." -ForegroundColor Yellow
    winget install JanDeDobbeleer.OhMyPosh
}

# Define local and remote config paths
$repoConfigUrl = "https://raw.githubusercontent.com/yourusername/Windows-Terminal-Profile/main/20211104-sarath-terminal.json"
$tempConfigPath = "$env:TEMP\20211104-sarath-terminal.json"

# Detect environment: Home vs Work
if ($env:COMPUTERNAME -match "HOME-LAPTOP") {
    $localPoshConfigPath = "E:\windows-terminal\oh-my-posh\20211104-sarath-terminal.json"
} else {
    $localPoshConfigPath = "$env:OneDrive\Documents\PowerShell\Themes\20211104-sarath-terminal.json"
}

# Function to download config from GitHub
function Get-RemoteConfig {
    try {
        Invoke-WebRequest -Uri $repoConfigUrl -OutFile $tempConfigPath -ErrorAction Stop
        return $tempConfigPath
    } catch {
        Write-Host "⚠ Unable to download Oh My Posh config from GitHub. Using local copy." -ForegroundColor Yellow
        return $localPoshConfigPath
    }
}

# Determine the configuration file to use
$poshConfigPath = Get-RemoteConfig

# Ensure proper escaping of file path
$poshConfigPathEscaped = "`"$poshConfigPath`""

# Fix Oh My Posh command in profile
$ohMyPoshCommand = "oh-my-posh --init --shell pwsh --config $poshConfigPathEscaped | Invoke-Expression"

# Add the corrected command to profile if not already present
$profilePath = $PROFILE
$profileContent = Get-Content $profilePath -Raw
if ($profileContent -notmatch "oh-my-posh") {
    Add-Content -Path $profilePath -Value "`n$ohMyPoshCommand"
    Write-Host "✔ Updated PowerShell Profile with Oh My Posh configuration." -ForegroundColor Green
} else {
    Write-Host "✔ Oh My Posh configuration already exists in profile." -ForegroundColor Yellow
}

# Reload PowerShell Profile
. $PROFILE
Write-Host "✔ PowerShell Profile reloaded successfully!" -ForegroundColor Green
