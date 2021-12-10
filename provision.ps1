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

Write-Host 'Install Chocolaty'
Write-Host "###################################################################"
Start-Process "powershell.exe" `
  -ArgumentList "$ScriptPath\scripts\chocolaty.ps1" -Wait

Write-Host 'Install Git'
Write-Host "###################################################################"
Start-Process "powershell.exe" `
  -ArgumentList "$ScriptPath\scripts\git.ps1" -Wait

Write-Host 'Install Metatrader 4'
Write-Host "###################################################################"
Start-Process -ArgumentList '/auto' `
  -FilePath "$ScriptPath\mt4setup.exe" -Wait

Write-Host 'Install Metatrader 5'
Write-Host "###################################################################"
Start-Process -ArgumentList '/auto' `
  -FilePath "$ScriptPath\mt5setup.exe" -Wait

Rename-Computer -NewName $hostName -Force

Write-Host 'Restarting'
Write-Host "###################################################################"
Start-Process `
  -ArgumentList '/c "timeout /t 3 /nobreak && shutdown -r -f -t 0"' `
  -FilePath "cmd.exe" `
  -WindowStyle Hidden

Exit 0
