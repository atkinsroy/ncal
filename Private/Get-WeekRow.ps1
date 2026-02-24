function Get-WeekRow {
    <#
        .NOTES
        Helper function for Get-NCalendar. Displays the week number beneath each column.

        Uses a .Net call to obtain the week number for the first week of the month for the required culture. We use 
        the specified first day of the week to ensure the week numbers align (although this is not culturally 
        correct). Otherwise, we are using the default first day of the week for the required culture.

        The other thing we're doing is ensuring the correct number of week numbers per month. Most of the time,
        this is five columns. However, if the first day of the month appears in the last day of the week position 
        and there are 30 or 31 days in the month, then there are 6 columns. If it appears in the next to last 
        position, and there 31 days, then are 6 columns. This equates to Index = -5 or -4 respectively.  

        The only other combination is when there are 28 days in February, and the first day is position 1 (Index = 1).
        In this case, there are only 4 columns.

        All cultures are fine, but calendars (typically the Asian Lunar calendars) don't show correct week numbers.
        This is because non-default calendars are inheriting DateTimeFormat from some Culture (which typically
        uses Gregorian by default). DateTimeFormat is used to calculate the week number of the first week in the
        month. I these situations, don't allow week row being displayed.

        The GetWeekOf year method is used on the calendar object below. This is "flexible" in nature, designed to
        work with various cultures. So, in practice, this method doesn't always following the ISO 8601 standard.
        Microsoft acknowledges this issue and has provided a dedicated class in modern .NET for ISO-compliant
        week numbers, as follows:
        $week = [System.Globalization.ISOWeek]::GetWeekOfYear($Date)

        However, this method doesn't accommodate the variable FirstDayOfWeek parameter, so some weeks would appear
        missaligned. In addition, it only works for Gregorian calendar.

        https://www.epochconverter.com/Weeks/2026

        Note: Linux ncal is incorrectly showing week numbers, according to above web site.

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Globalization.CultureInfo]$Culture,

        [Parameter(Mandatory, Position = 1)]
        [System.Globalization.Calendar]$Calendar,

        [Parameter(Mandatory, Position = 2)]
        [ValidateRange(1, 13)]
        [Int]$Month,

        [Parameter(Mandatory, Position = 3)]
        [ValidateRange(1, 9999)]
        [Int]$Year,

        [Parameter(Mandatory, Position = 4)]
        [ValidateSet('Friday', 'Saturday', 'Sunday', 'Monday')]
        [String]$FirstDayOfWeek,

        [Parameter(Mandatory, Position = 5)]
        [ValidateRange(-5, 1)]
        [Int]$Index,

        [Parameter(Position = 6)]
        [Bool]$JulianSpecified
    )

    process {
        $FirstDate = $Calendar.ToDateTime($Year, $Month, 1, 0, 0, 0, 0, $Calendar.Eras[0] )
        $DayPerMonth = $Calendar.GetDaysInMonth($Year, $Month)
        $CultureWeekRule = $Culture.DateTimeFormat.CalendarWeekRule

        # Adjust the starting week number, based on the first day of the week.
        $StartWeekDay = switch ($FirstDayOfWeek) {
            'Friday' { 5 }
            'Saturday' { 6 }
            'Sunday' { 0 }
            'Monday' { 1 }
            default { $Culture.DateTimeFormat.FirstDayOfWeek }
        }
        
        # This is the starting week number of this month, taking into account the starting week day.
        $FirstWeek = $Culture.Calendar.GetWeekOfYear($FirstDate, $CultureWeekRule, $StartWeekDay)
        #$FirstWeek = [System.Globalization.ISOWeek]::GetWeekOfYear($FirstDate)

        [String]$WeekRow = ''
        [Int]$WeekCount = 5

        # month starts last day of week and has at least 30 days is 6 columns wide
        if (-5 -eq $Index -and $DayPerMonth -ge 30) {
            $WeekCount = 6
        }
        # month starts next to last day of week and has over 30 day is 6 columns wide
        elseif (-4 -eq $Index -and $DayPerMonth -gt 30) {
            $WeekCount = 6
        }
        # February in some calendars that starts on the first day of the week is 4 columns wide
        elseif (1 -eq $Index -and $DayPerMonth -eq 28) {
            $WeekCount = 4
        }

        if ($true -eq $JulianSpecified) {
            $PadRow = 24
            $PadDay = 3
        }
        else {
            $PadRow = 19
            $PadDay = 2
        }

        $LastWeek = $FirstWeek + ($WeekCount - 1)
        $FirstWeek..$LastWeek | ForEach-Object {
            #if ($_ -gt 52) {
            #    $WeekRow += "{0,$PadDay} " -f ($_ - 52)
            #}
            #else {
            $WeekRow += "{0,$PadDay} " -f $_
            #}
        }
    
        $OutString = "$WeekRow".PadRight($PadRow, ' ')
        Write-Output $OutString
    } # end process
}
