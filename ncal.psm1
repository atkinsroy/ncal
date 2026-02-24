###############################################################################
#
# ncal.psm1
# 
# Description:
#     This module provides calendar functionality similar to the Linux ncal and
#     cal commands, with additional features for displaying dates in various 
#     calendars supported by .NET.
# 
# Website:
#     https://github.com/atkinsroy/ncal
#
# Author:
#     Roy Atkins
#
###############################################################################
$publicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'
$privatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'

$Public = @()
$Private = @()

if (Test-Path -Path $publicPath) {
    $Public = @(Get-ChildItem -Path (Join-Path -Path $publicPath -ChildPath '*.ps1') -File)
}

if (Test-Path -Path $privatePath) {
    $Private = @(Get-ChildItem -Path (Join-Path -Path $privatePath -ChildPath '*.ps1') -File)
}

foreach ($Module in @($Public + $Private)) {
    try {
        . $Module.FullName
    } 
    catch {
        throw "Failed to import function $($Module.FullName): $_"
    }
}

$aliasesToExport = @()

if (Get-Command -Name 'Get-NCalendar' -ErrorAction SilentlyContinue) {
    Set-Alias -Name 'ncal' -Value 'Get-NCalendar' -Scope Local
    $aliasesToExport += 'ncal'
}

if (Get-Command -Name 'Get-Calendar' -ErrorAction SilentlyContinue) {
    Set-Alias -Name 'cal' -Value 'Get-Calendar' -Scope Local
    $aliasesToExport += 'cal'
}

$publicFunctionNames = @($Public.BaseName | Where-Object { $_ })

if ($publicFunctionNames.Count -gt 0 -and $aliasesToExport.Count -gt 0) {
    Export-ModuleMember -Function $publicFunctionNames -Alias $aliasesToExport
}
elseif ($publicFunctionNames.Count -gt 0) {
    Export-ModuleMember -Function $publicFunctionNames
}
elseif ($aliasesToExport.Count -gt 0) {
    Export-ModuleMember -Alias $aliasesToExport
}