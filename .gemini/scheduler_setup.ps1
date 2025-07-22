# ChatStash Windows Task Scheduler Setup Script
# Run as Administrator to configure automated daily exports

param(
    [string]$TaskName = "ChatStash-DailyExport",
    [string]$ExecutionTime = "03:00",
    [string]$ChatStashPath = "$env:USERPROFILE\ChatStash",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "Setting up ChatStash Task Scheduler configuration..." -ForegroundColor Green

# Verify ChatStash installation
if (-not (Test-Path $ChatStashPath)) {
    Write-Error "ChatStash not found at $ChatStashPath. Please install ChatStash first."
    exit 1
}

# Create necessary directories
$LogDir = Join-Path $ChatStashPath "logs"
$ScriptDir = Join-Path $ChatStashPath "scripts"

New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
New-Item -ItemType Directory -Path $ScriptDir -Force | Out-Null

# Create launcher script
$LauncherScript = @'
# ChatStash Launcher Script
$ErrorActionPreference = "Stop"
$LogPath = "{0}\logs\scheduler.log"
$ChatStashPath = "{1}"

try {
    # Verify WSL2 availability
    $wslStatus = wsl --status 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "WSL2 not available: $wslStatus"
    }
    
    # Set environment variables
    $env:CHATSTASH_CONFIG_PATH = "$ChatStashPath\config"
    $env:CHATSTASH_DATA_PATH = "$ChatStashPath\data"
    
    # Log start
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "[$timestamp] Starting ChatStash daily export"
    
    # Change to ChatStash directory in WSL2
    $wslPath = $ChatStashPath -replace "C:\\", "/mnt/c/" -replace "\\", "/"
    
    # Execute gemini-cli workflow
    $result = wsl --cd $wslPath gemini-cli run .gemini/export_workflow.yml 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Add-Content -Path $LogPath -Value "[$timestamp] Export completed successfully"
        Add-Content -Path $LogPath -Value "Output: $result"
    } else {
        throw "Gemini CLI execution failed with exit code $LASTEXITCODE. Output: $result"
    }
}
catch {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $errorMsg = "[$timestamp] ERROR: $($_.Exception.Message)"
    Add-Content -Path $LogPath -Value $errorMsg
    
    # Write to Windows Event Log
    Write-EventLog -LogName Application -Source "ChatStash" -EventId 1001 -EntryType Error -Message $errorMsg
    
    exit 1
}
'@ -f $LogDir, $ChatStashPath

$LauncherPath = Join-Path $ScriptDir "chatstash_launcher.ps1"
$LauncherScript | Out-File -FilePath $LauncherPath -Encoding UTF8

Write-Host "Created launcher script at: $LauncherPath" -ForegroundColor Yellow

# Create Windows Event Log source
try {
    New-EventLog -LogName Application -Source "ChatStash" -ErrorAction SilentlyContinue
    Write-Host "Created Windows Event Log source: ChatStash" -ForegroundColor Yellow
} catch {
    Write-Warning "Could not create Event Log source (may require admin privileges): $($_.Exception.Message)"
}

# Remove existing task if Force is specified
if ($Force) {
    try {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "Removed existing task: $TaskName" -ForegroundColor Yellow
    } catch {
        # Task doesn't exist, continue
    }
}

# Create scheduled task
try {
    # Define task action
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$LauncherPath`""
    
    # Define task trigger (daily at specified time)
    $Trigger = New-ScheduledTaskTrigger -Daily -At $ExecutionTime
    
    # Define task settings
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable
    
    # Define task principal (run with current user credentials)
    $Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
    
    # Register the task
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Description "ChatStash automated daily conversation export"
    
    Write-Host "Successfully created scheduled task: $TaskName" -ForegroundColor Green
    Write-Host "Task will run daily at: $ExecutionTime" -ForegroundColor Green
    
} catch {
    Write-Error "Failed to create scheduled task: $($_.Exception.Message)"
    exit 1
}

# Create configuration template if it doesn't exist
$ConfigPath = Join-Path $ChatStashPath "config\chatstash.yml"
$ConfigDir = Split-Path $ConfigPath -Parent

if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
}

if (-not (Test-Path $ConfigPath)) {
    $ConfigTemplate = @'
# ChatStash Configuration
version: 1.0

# ChatGPT Settings
chatgpt:
  base_url: "https://chat.openai.com"
  session_timeout: 3600  # seconds
  retry_attempts: 3
  
# Export Settings
export:
  format: "json"  # json, markdown, csv
  include_metadata: true
  days_to_export: 1
  
# Database Settings
database:
  type: "sqlite"  # sqlite, postgresql
  path: "data/database/conversations.db"
  
# Cloud Storage
cloud_storage:
  provider: "dropbox"  # dropbox, googledrive, onedrive
  sync_interval: "daily"
  retention_days: 365
  
# Notifications
notifications:
  email:
    enabled: false
    smtp_server: ""
    from_address: ""
    to_address: ""
  
# Logging
logging:
  level: "INFO"  # DEBUG, INFO, WARN, ERROR
  max_file_size: "10MB"
  backup_count: 5
'@
    
    $ConfigTemplate | Out-File -FilePath $ConfigPath -Encoding UTF8
    Write-Host "Created configuration template at: $ConfigPath" -ForegroundColor Yellow
    Write-Host "Please edit this file with your specific settings." -ForegroundColor Yellow
}

# Display next steps
Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
Write-Host "Next steps:"
Write-Host "1. Edit configuration file: $ConfigPath" -ForegroundColor Cyan
Write-Host "2. Install ChatStash dependencies in WSL2" -ForegroundColor Cyan
Write-Host "3. Configure ChatGPT credentials" -ForegroundColor Cyan
Write-Host "4. Test the task: Start-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Cyan
Write-Host "5. Monitor logs: $LogDir\scheduler.log" -ForegroundColor Cyan

Write-Host "`nTask Details:" -ForegroundColor Yellow
Write-Host "  Name: $TaskName"
Write-Host "  Schedule: Daily at $ExecutionTime"
Write-Host "  Script: $LauncherPath"
Write-Host "  Logs: $LogDir\scheduler.log"

Write-Host "`nTo modify or remove the task, use:" -ForegroundColor Yellow
Write-Host "  Get-ScheduledTask -TaskName '$TaskName'"
Write-Host "  Unregister-ScheduledTask -TaskName '$TaskName'"