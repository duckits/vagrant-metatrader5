# Are we running in 32-bit mode?
if ($PSHOME -like "*SysWOW64*") {
  Write-Warning "Restarting this script under 64-bit Windows PowerShell."
  # Restart this script under 64-bit Windows PowerShell.
  #   (\SysNative\ redirects to \System32\ for 64-bit mode)
  & (Join-Path ($PSHOME -replace "SysWOW64", "SysNative") powershell.exe) -File `
    (Join-Path $PSScriptRoot $MyInvocation.MyCommand) @args
  # Exit 32-bit script.
  Exit $LastExitCode
}

$ErrorActionPreference = "Stop"

Write-Host "###################################################################"
Write-Host "Executing Script:" $PSCommandPath

& choco install -y git -params '"/GitAndUnixToolsOnPath"' | Out-String

# PowerShell Gallery
# If you have at least PowerShell 5 or PowerShell 4 with PackageManagement installed, you can use the package manager to install posh-git for you.

# Write-Host "###################################################################"
# Write-Host "Posh-Git Install"

# # More information about PowerShell Gallery: https://docs.microsoft.com/en-us/powershell/gallery/overview
# Install-Module posh-git -Scope CurrentUser -Force

# # Update PowerShell Prompt
# # To include git information in your prompt, the posh-git module needs to be imported. To have posh-git imported every time PowerShell starts, execute the Add-PoshGitToProfile command which will add the import statement into you $profile script. This script is executed everytime you open a new PowerShell console. Keep in mind, that there are multiple $profile scripts. E. g. one for the console and a separate one for the ISE.

# New-Alias -Name git -Value "$env:systemdrive\Program files\Git\bin\git.exe"

# Import-Module posh-git

# Add-PoshGitToProfile -AllHosts
