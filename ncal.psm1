###############################################################################
#
# ncal.psm1
# 
# Description:
#     This module provides calendar functionality similar to the Linux ncal and
#     cal commands, with additional features for displaying dates in various 
#     cultures and calendars supported by .NET.
# 
# Website:
#     https://github.com/atkinsroy/ncal
#
# Author:
#     Roy Atkins
#
###############################################################################
$PublicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'
$PrivatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'

$Public = @()
$Private = @()

if (Test-Path -Path $PublicPath) {
    $Public = @(Get-ChildItem -Path (Join-Path -Path $PublicPath -ChildPath '*.ps1') -File | Sort-Object -Property Name)
}

if (Test-Path -Path $PrivatePath) {
    $Private = @(Get-ChildItem -Path (Join-Path -Path $PrivatePath -ChildPath '*.ps1') -File | Sort-Object -Property Name)
}

foreach ($Module in @($Public + $Private)) {
    try {
        . $Module.FullName
    } 
    catch {
        throw "Failed to import function $($Module.FullName): $_"
    }
}

$AliasesToExport = @()

if (Get-Command -Name 'Get-NCalendar' -ErrorAction SilentlyContinue) {
    Set-Alias -Name 'ncal' -Value 'Get-NCalendar' -Scope Local
    $AliasesToExport += 'ncal'
}

if (Get-Command -Name 'Get-Calendar' -ErrorAction SilentlyContinue) {
    Set-Alias -Name 'cal' -Value 'Get-Calendar' -Scope Local
    $AliasesToExport += 'cal'
}

$PublicFunctionNames = @($Public.BaseName | Where-Object { $_ })

if ($PublicFunctionNames.Count -gt 0 -and $AliasesToExport.Count -gt 0) {
    Export-ModuleMember -Function $PublicFunctionNames -Alias $AliasesToExport
}
elseif ($PublicFunctionNames.Count -gt 0) {
    Export-ModuleMember -Function $PublicFunctionNames
}
elseif ($AliasesToExport.Count -gt 0) {
    Export-ModuleMember -Alias $AliasesToExport
}