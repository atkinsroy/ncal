#Requires -Version 7.2 

function Get-StartWeekIndex {
    <#
        .NOTES
        The first day index is always 1 through 7, Monday to Sunday. This function returns an index, based on the 
        real/desired first day of the week and the actual start day. This will be a number between -5 and 1. When 
        we reach an index=1, we start printing (Get-Ncal/Get-Cal), otherwise we print a space.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Globalization.CultureInfo]$Culture,

        [Parameter(Mandatory, Position = 1)]
        [ValidateSet('Friday', 'Saturday', 'Sunday', 'Monday')]
        [string]$StartWeekDay,

        [Int]$FirstDayIndex
    )

    process {
        # Monday = -2 thru Sunday = -8, which means Friday-Sunday start on next column so force 1, 0, -1 resp.
        if ('Friday' -eq $StartWeekDay) {
            $ThisIndex = -1 - $FirstDayIndex
            if ($ThisIndex -eq -6) {
                $ThisIndex = 1
            }
            elseif ($ThisIndex -eq -7) {
                $ThisIndex = 0
            }
            elseif ($ThisIndex -eq -8) {
                $ThisIndex = -1
            }
        }
        # Monday = -1 thru Sunday = -7 which mean both Saturday and Sunday start on next column, so force 1 and 0 resp.
        elseif ('Saturday' -eq $StartWeekDay) {
            $ThisIndex = 0 - $FirstDayIndex
            if ($ThisIndex -eq -6) {
                $ThisIndex = 1
            }
            elseif ($ThisIndex -eq -7) {
                $ThisIndex = 0
            }
        }
        elseif ('Sunday' -eq $StartWeekDay) {
            # Monday = 0 thru Sunday = -6, which would mean start on next column, so force Sunday to be 1
            $ThisIndex = 1 - $FirstDayIndex
            if ($ThisIndex -eq -6) {
                $ThisIndex = 1
            }
        }
        else {
            # Week starts Monday. Here we need Monday = 1 thru Sunday = -5
            $ThisIndex = 2 - $FirstDayIndex
            if ($ThisIndex -eq 2) {
                $ThisIndex = -5
            }
        }
        Write-Output $ThisIndex
    }
}