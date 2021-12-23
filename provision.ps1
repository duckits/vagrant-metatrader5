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

Write-Host 'Enable auto logon...'
Write-Host "###################################################################"
$logonPath = 'HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
Set-ItemProperty -Path $logonPath -Name AutoAdminLogon -Value 1
Set-ItemProperty -Path $logonPath -Name DefaultDomainName -Value $hostName
Set-ItemProperty -Path $logonPath -Name DefaultUserName -Value vagrant
Set-ItemProperty -Path $logonPath -Name DefaultPassword -Value vagrant

Write-Host 'Show File Extensions'
Write-Host "###################################################################"
Set-ItemProperty `
    -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
    -Name 'HideFileExt' `
    -Value 0

$ScriptPath = Split-Path $MyInvocation.InvocationName

# mt4setup downloaded from metatrader official installs mt5
# Write-Host 'Install MetaTrader 4'
# Write-Host "###################################################################"
# Start-Process -ArgumentList '/auto' `
#   -FilePath "$ScriptPath\mt4setup.exe" -Wait

Write-Host 'Install MetaTrader 4 (forexcom)'
Write-Host "###################################################################"
Start-Process -ArgumentList '/auto' `
  -FilePath "$ScriptPath\forexcom4setup.exe" -Wait

Write-Host 'Install MetaTrader 4 (ig)'
Write-Host "###################################################################"
Start-Process -ArgumentList '/auto' `
  -FilePath "$ScriptPath\ig4setup.exe" -Wait

Write-Host 'Install MetaTrader 4 (oanda)'
Write-Host "###################################################################"
Start-Process -ArgumentList '/auto' `
  -FilePath "$ScriptPath\oanda4setup.exe" -Wait

Write-Host 'Install MetaTrader 5'
Write-Host "###################################################################"
Start-Process -ArgumentList '/auto' `
  -FilePath "$ScriptPath\mt5setup.exe" -Wait

# before symlinking our custom metatrader code
# we need to ensure the applications have been launched at least once
# otherwise the expected directories won't exist.
Start-Process -FilePath "C:/Program Files (x86)/FOREX.com US/terminal.exe"
Start-Process -FilePath "C:/Program Files (x86)/IG MetaTrader 4 Terminal/terminal.exe"
Start-Process -FilePath "C:/Program Files (x86)/OANDA - Metatrader/terminal.exe"
Start-Process -FilePath "C:/Program Files/MetaTrader 5/terminal64.exe"

Start-Sleep -Seconds 60 # pause a minute to let applications launch

# get list of directories in c:/MQL
$directories = Get-ChildItem c:/MQL/ |
       Where-Object {$_.PSIsContainer} |
       Foreach-Object {$_.Name}

for ($i=0; $i -lt $directories.length; $i++) {
  $folder = $directories[$i]
  New-Item -ItemType SymbolicLink `
    -Path "C:/Program Files (x86)/FOREX.com US/MQL4/$folder/Custom" `
    -Target "c:/MQL/$folder"
  New-Item -ItemType SymbolicLink `
    -Path "C:/Program Files (x86)/IG MetaTrader 4 Terminal/MQL4/$folder/Custom" `
    -Target "c:/MQL/$folder"
  New-Item -ItemType SymbolicLink `
    -Path "C:/Program Files (x86)/OANDA - Metatrader/MQL4/$folder/Custom" `
    -Target "c:/MQL/$folder"
  New-Item -ItemType SymbolicLink `
    -Path "C:/Program Files/MetaTrader 5/MQL5/$folder/Custom" `
    -Target "c:/MQL/$folder"
}

Rename-Computer -NewName $hostName -Force

Write-Host 'Restarting'
Write-Host "###################################################################"
Start-Process `
  -ArgumentList '/c "timeout /t 3 /nobreak && shutdown -r -f -t 0"' `
  -FilePath "cmd.exe" `
  -WindowStyle Hidden

Exit 0
