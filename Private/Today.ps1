#Requires -Version 7.2 

function Get-Today {
    [CmdletBinding()]
    param (
        [System.Globalization.CultureInfo]$Culture
    )
    process {
        $Now = Get-Date
        [PSCustomObject]@{
            'Year'  = $Culture.Calendar.GetYear($Now)
            'Month' = $Culture.Calendar.GetMonth($Now)
            'Day'   = $Culture.Calendar.GetDayOfMonth($Now)
        }
    }
}