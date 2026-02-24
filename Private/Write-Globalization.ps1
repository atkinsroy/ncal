function Write-Globalization {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Globalization.CultureInfo]$Culture,

        [Parameter(Mandatory)]
        [System.Globalization.Calendar]$Calendar   
    )

    process {
        $CalendarString = $($Calendar.ToString().Replace('System.Globalization.', '').Replace('Calendar', ' Calendar'))
        Write-Output "`n$($PSStyle.Reverse)-- $($Culture.DisplayName) ($($Culture.Name)), $CalendarString --$($PSStyle.ReverseOff)`n"
    }
}