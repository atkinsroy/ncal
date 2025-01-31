#Requires -Version 7.2 

function Get-WeekRow {
    <#
        .NOTES
        Helper function for Get-NCalendar. Prints the week number to display beneath each column

        Uses a .Net call to obtain the week number for the first week of the month for the required culture. We use 
        the specified first day of the week to ensure the week numbers align (although this is not culturally 
        correct). Otherwise, we are using the default first day of the week for the required culture.
        
        The other thing we're doing is ensuring the correct number of week numbers per month. Most of the time,
        this is five columns. However, if the first day of the month appears in the last day of the week position 
        and there are 30 or 31 days in the month, then there are 6 columns. If it appears in the next to last 
        position, and there 31 days, then are 6 columns. This equates to Index = -5 or -4 respectively.  

        The only other combination is when there are 28 days in February, and the first day is position 1 (Index = 1).
        In this case, there are only 4 columns.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Globalization.CultureInfo]$Culture,

        [Parameter(Mandatory, Position = 1)]
        [ValidateRange(1, 12)]
        [Int]$Month,

        [Parameter(Mandatory, Position = 2)]
        [ValidateRange(1000, 9999)]
        [Int]$Year,

        [Parameter(Mandatory, Position = 3)]
        [ValidateSet('Friday', 'Saturday', 'Sunday', 'Monday')]
        [String]$FirstDayOfWeek,

        [Parameter(Mandatory, Position = 3)]
        [ValidateRange(-5, 1)]
        [Int]$Index,

        [Parameter(Position = 4)]
        [Bool]$JulianSpecified
    )

    process {
        $ThisDate = '{0}/{1:D2}/{2}' -f '01', $Month, $Year
        $FirstDate = [datetime]::ParseExact($ThisDate, 'dd/MM/yyyy', $Culture)
        $DayPerMonth = $Culture.Calendar.GetDaysInMonth($Year, $Month)
        $CultureWeekRule = $Culture.DateTimeFormat.CalendarWeekRule
        Write-Verbose "WeekRow - $Month, $Year, $Index"

        # Adjust the starting week number, based on the first day of the week.
        if ('Friday' -eq $FirstDayOfWeek) {
            $StartWeekDay = 5
        }
        if ('Saturday' -eq $FirstDayOfWeek) {
            $StartWeekDay = 6
        }
        elseif ('Sunday' -eq $FirstDayOfWeek) {
            $StartWeekDay = 0
        }
        elseif ('Monday' -eq $FirstDayOfWeek) {
            $StartWeekDay = 1
        }
        else {
            #can't be necessary, but use default for the requested culture, for illustration.
            $StartWeekDay = $Culture.DateTimeFormat.FirstDayOfWeek
        }
        # This is the starting week number of this month, taking into account the starting week day.
        $FirstWeek = $Culture.Calendar.GetWeekOfYear($FirstDate, $CultureWeekRule, $StartWeekDay)

        [String]$WeekRow = ''
        [Int]$WeekCount = 5

        if (-5 -eq $Index -and $DayPerMonth -ge 30) {
            $WeekCount = 6
        }
        elseif (-4 -eq $Index -and $DayPerMonth -gt 30) {
            $WeekCount = 6
        }
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
            if ($_ -gt 52) {
                $WeekRow += "{0,$PadDay} " -f ($_ - 52)
            }
            else {
                $WeekRow += "{0,$PadDay} " -f $_
            }
        }
    
        $OutString = "$WeekRow".PadRight($PadRow, ' ')
        Write-Output $OutString
        #Write-Verbose "|$OutString| Week row length $($OutString.Length)"
    } # end process
}
