function Get-NcalRow {
    <# 
        .NOTES
        Helper function for Get-NCalendar. Prints one row of calendar output, given an Index corresponding to the
        first day of the month.
    #>
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Globalization.Calendar]$Calendar,

        [Parameter(Mandatory, Position = 1)]
        [Int]$Index,
        
        [Parameter(Position = 2)]
        [ValidateRange(28, 31)]
        [Int]$DayPerMonth,

        [Parameter(Position = 3)]
        [ValidateRange(1, 13)]
        [Int]$Month,

        [Parameter(Position = 4)]
        [ValidateRange(1, 9999)]
        [Int]$Year,

        [Parameter(Position = 5)]
        [Object]$Highlight,

        [Parameter(Position = 6)]
        [Bool]$JulianSpecified
    ) 

    begin {
        $WeekDay = $Index
        $Row = ''
        $JulianDay = 0

        if ($JulianSpecified) {
            $PadRow = 24
            $PadDay = 3
        }
        else {
            $PadRow = 19
            $PadDay = 2
        }
    }

    process {
        do {
            if ($WeekDay -lt 1) {
                $Row += "{0,$PadDay} " -f $null
            }
            else {
                if ($JulianSpecified) {
                    try {
                        $UseDate = $Calendar.ToDateTime($Year, $Month, $WeekDay, 0, 0, 0, 0, $Calendar.Eras[0] )
                        $JulianDay = $Calendar.GetDayOfYear($UseDate)
                        $Row += "{0,$PadDay} " -f $JulianDay
                    }
                    catch {
                        Write-Error "day beyond day/month - $($_.Message)"
                    }
                }
                else {
                    $Row += "{0,$PadDay} " -f $WeekDay
                }
            }
            $WeekDay += 7
        }
        until ($WeekDay -gt $DayPerMonth)
        $OutString = "$($Row.TrimEnd())".PadRight($PadRow, ' ')
        <#
            The secret to not screwing up formatted strings with non-printable characters is to mess with the string 
            after the string is padded to the right length.
        #>
        if ( ($Highlight.Today -gt 0) -and $JulianSpecified) {
            $UseDate = $Calendar.ToDateTime($Year, $Month, $Highlight.Today, 0, 0, 0, 0, $Calendar.Eras[0] )
            $JulianDay = $Calendar.GetDayOfYear($UseDate)
        
            if ($OutString -match "\b$JulianDay\b") {
                $OutString = $OutString -replace "$JulianDay\b", "$($Highlight.DayStyle)$JulianDay$($Highlight.DayReset)"
            }
        }
        elseif ( ($Highlight.Today -gt 0) -and ($OutString -match "\b$($Highlight.Today)\b")) {
            if ($Highlight.Today -lt 10) {
                $OutString = $OutString -replace "\s$($Highlight.Today)\b", "$($Highlight.DayStyle) $($Highlight.Today)$($Highlight.DayReset)"
            }
            else {
                $OutString = $OutString -replace "$($Highlight.Today)\b", "$($Highlight.DayStyle)$($Highlight.Today)$($Highlight.DayReset)"
            }
        }
        Write-Output $OutString
    }
}