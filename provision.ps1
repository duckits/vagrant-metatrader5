Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
trap {
    Write-Host
    Write-Host 'ERROR: $_'
    Write-Host (($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1')
    Write-Host (($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1')
    Write-Host
    Write-Host 'Sleeping for 60m to give you time to look around the virtual machine before self-destruction...'
    Start-Sleep -Seconds (60*60)
    Exit 1
}

$hostName = "MetaTrader"

Write-Host "###################################################################"
Write-Host "Enable auto login vagrant user"
Write-Host "###################################################################"
$logonPath = 'HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
Set-ItemProperty -Path $logonPath -Name AutoAdminLogon -Value 1
Set-ItemProperty -Path $logonPath -Name DefaultDomainName -Value $hostName
Set-ItemProperty -Path $logonPath -Name DefaultUserName -Value vagrant
Set-ItemProperty -Path $logonPath -Name DefaultPassword -Value vagrant

Write-Host "###################################################################"
Write-Host "Always show file extensions"
Write-Host "###################################################################"
Set-ItemProperty `
    -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
    -Name 'HideFileExt' `
    -Value 0

Write-Host "###################################################################"
Write-Host "Enable audio service"
Write-Host "###################################################################"
Get-Service | Where {$_.Name -match "audio"} | format-table -autosize
Get-Service | Where {$_.Name -match "audio"} | start-service
Get-Service | Where {$_.Name -match "audio"} | set-service -StartupType "Automatic"
# Validate our startup changes (Should say- StartMode:Auto)
Get-WmiObject -class win32_service -filter "Name='AudioSrv'"

Set-TimeZone -Name "Central Standard Time"

$ScriptPath = Split-Path $MyInvocation.InvocationName

# Define a list of MetaTrader Terminals to install
$terminals = @('Demo','Live')

for ($t=0; $t -lt $terminals.length; $t++) {
  $terminal = $terminals[$t]
  $install = "MetaTrader 5 - $terminal"
  $installDir = "C:/Program Files/$install"
  $dataDir = "$installDir/MQL5"
  $mqlSourceDir = "$Home/MQL5"

  Write-Host "###################################################################"
  Write-Host "Install $install"
  Write-Host "###################################################################"
  Start-Process -ArgumentList '/auto' -FilePath "$ScriptPath\mt5setup.exe" -Wait

  # remove default desktop shortcut
  Remove-Item -Path "C:/Users/*/Desktop/MetaTrader 5.lnk"
  Remove-Item -Path "C:/Users/*/Desktop/MetaEditor 5.lnk"

  # remove default start menu shortcuts
  Remove-Item -Path "$Env:ProgramData/Microsoft/Windows/Start Menu/Programs/MetaTrader 5" -Recurse

  # move /auto install to new install path
  Rename-Item -Path "C:/Program Files/Metatrader 5" -NewName $installDir

  # create new desktop shortcut
  $WshShell = New-Object -comObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut("$Home/Desktop/$terminal.lnk")
  $Shortcut.TargetPath = "$installDir/terminal64.exe"
  $Shortcut.Save()

  # link MQL5 directory into $dataDir
  New-Item -ItemType Junction -Path $dataDir -Value $mqlSourceDir
}

# remove user start menu shortcuts
Remove-Item -Path "$Env:APPDATA/Microsoft/Windows/Start Menu/Programs/Oracle VM VirtualBox guest Additions" -Recurse

Write-Host "###################################################################"
Write-Host "Rename host and restart"
Write-Host "###################################################################"
Rename-Computer -NewName $hostName -Force
Start-Process `
  -ArgumentList '/c "timeout /t 3 /nobreak && shutdown -r -f -t 0"' `
  -FilePath "cmd.exe" `
  -WindowStyle Hidden

Exit 0
