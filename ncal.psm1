###############################################################################
#
# ncal.psm1
# 
# Description:
#     Create calendar in the command line, similar to the Linux ncal
#     and cal commands, only better!
# 
# Website:
#     https://github.com/atkinsroy/ncal
#
# Author:
#     Roy Atkins.
#
###############################################################################

$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1) 

foreach ($Module in @($Public + $Private)) {
    try {
        . $Module.FullName
    } 
    catch {
        Write-Error -Message "Failed to import function $($Module.FullName): $_"
    }
}

Export-ModuleMember -Function $Public.BaseName
Export-ModuleMember -Function $Private.BaseName
