function Get-Today {
    <#
        .NOTES
        Helper function for Get-FirstDayOfMonth and Get-Highlight . Returns a custom object with the current date
        in the specified calendar.
    #>
    [CmdletBinding()]
    param (
        [System.Globalization.Calendar]$Calendar
    )
    process {
        $Now = Get-Date
        [PSCustomObject]@{
            'DateTime' = $Now #Always shown in local calendar
            'Year'     = $Calendar.GetYear($Now)
            'Month'    = $Calendar.GetMonth($Now)
            'Day'      = $Calendar.GetDayOfMonth($Now)
        }
    }
}