
Write-Host "Welcome to the initialisation of the Windows Terminal Settings" -ForegroundColor Green

# Set variables for initialisation
$folder = "Projects"
$drive = Read-Host -Prompt "Please enter the location of the projects folder"
$path = "\"
$drivePath = $drive + $path
$folderPath = $drivepath + $folder + $path + "windows-terminal\"
#Get-ChildItem -Recurse "Projects" -Directory -ErrorAction SilentlyContinue -Path $drivePath

Write-Host "" $folderPath -ForegroundColor Green

# Check if environment variable exists for the windows terminal
#if (-not [System.Environment]::GetEnvironmentVariable('WindowsTerminalGit','User'))
#{
#    # create a user environment variable if it doesn't exist
#    "doesn't exist"
#}

#if (-not (Test-Path $env:HOMEPATH)) {Write-Host "Env Variable Exists" -f Green}
#else {
#    Write-Host "Var does not exist" -f Red
#}