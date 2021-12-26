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

# Write-Host "###################################################################"
# Write-Host 'Install MetaTrader 4 (forexcom)'
# Write-Host "###################################################################"
# Start-Process -ArgumentList '/auto' -FilePath "$ScriptPath\forexcom4setup.exe" -Wait
# $installDir = "C:/Program Files (x86)/FOREX.com US"

# Write-Host "###################################################################"
# Write-Host 'Install MetaTrader 4 (ig)'
# Write-Host "###################################################################"
# Start-Process -ArgumentList '/auto' -FilePath "$ScriptPath\ig4setup.exe" -Wait
# $installDir = "C:/Program Files (x86)/IG Metatrader 4 Terminal"

Write-Host "###################################################################"
Write-Host 'Install MetaTrader 4 (oanda)'
Write-Host "###################################################################"
Start-Process -ArgumentList '/auto' -FilePath "$ScriptPath\oanda4setup.exe" -Wait
$installDir = 'C:/Program Files (x86)/OANDA - Metatrader'

# # mt4setup downloaded from metatrader official actually installs mt5
# Write-Host "###################################################################"
# Write-Host 'Install MetaTrader 4'
# Write-Host "###################################################################"
# Start-Process -ArgumentList '/auto' -FilePath "$ScriptPath\mt4setup.exe" -Wait
# # $installDir = "C:/Program Files/Metatrader"

# start the MetaTrader 5 terminal to generate the default MQL5 folders
# Start-Process -FilePath "$installDir/terminal.exe"
# Start-Sleep -Seconds 60 # pause a minute to let applications launch

$dirs = @('config','MQL4','profiles','templates')
# symlink our custom configuration into metatrader install
for ($i=0; $i -lt $dirs.length; $i++) {
  $dir = $dirs[$i]
  $localPath = "$installDir/$dir"
  If (test-path $localPath){
    Rename-Item -path $localpath -newName "$localPath-og"
  }
  New-Item -ItemType SymbolicLink -Path $localPath -Target "C:/Users/vagrant/mt4/$dir/"
}

Write-Host "###################################################################"
Write-Host 'Install MetaTrader 5'
Write-Host "###################################################################"
Start-Process -ArgumentList '/auto' -FilePath "$ScriptPath\mt5setup.exe" -Wait
# start the MetaTrader 5 terminal to generate the default MQL5 folders
# Start-Process -FilePath "C:/Program Files/MetaTrader 5/terminal64.exe"
# Start-Sleep -Seconds 60 # pause a minute to let applications launch

# symlink our custom configuration into metatrader 5 install
$dirs = @('Config','MQL5','Profiles')
for ($i=0; $i -lt $dirs.length; $i++) {
  $dir = $dirs[$i]
  $localPath = "C:/Program Files/MetaTrader 5/$dir"
  If (test-path $localPath){ # rename directory if it exists
    Rename-Item -path $localpath -newName "$localPath-og"
  }
  New-Item -ItemType SymbolicLink -Path $localPath -Target "C:/Users/vagrant/mt5/$dir"
}

Rename-Computer -NewName $hostName -Force

Write-Host 'Restarting'
Write-Host "###################################################################"
Start-Process `
  -ArgumentList '/c "timeout /t 3 /nobreak && shutdown -r -f -t 0"' `
  -FilePath "cmd.exe" `
  -WindowStyle Hidden

Exit 0
