function Get-FirstDayOfMonth {
    <# 
        .NOTES
        Helper function for Get-NCalendar and Get-Calendar that returns the date and day position of the first day 
        of each required month, using the specified calendar. This function performs the parameter validation for 
        both ncal and cal.

        Specifically not using $PSBoundParameters.ContainsKey() for Month and Year parameters as these are not
        mandatory, but we want to validate them if they are specified. Parameter validation has already been
        performed on the calling function.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Globalization.Calendar]$Calendar,
        
        # Could be an integer between 1 and 13 or the same with an 'f' or 'p' suffix
        [Parameter(Position = 1)]
        [String]$Month,
        
        [Parameter(Position = 2)]
        [Int]$Year,

        [Parameter(Position = 3)]
        [Int]$Before,
        
        [Parameter(Position = 4)]
        [Int]$After,

        [Parameter(Position = 5)]
        [Switch]$Three
    )

    process {
        $Now = Get-Today -Calendar $Calendar
        Write-Verbose "today year = $($Now.Year), today month = $($Now.Month), today day = $($Now.Day)"
        Write-Verbose '--------------------------------------'

        if ($null -ne $Month -and '' -ne $Month) {
            [Int]$AfterOffset = 0

            if (0 -eq $Year) { 
                $Year = $Now.Year
                $YearSpecified = $false
            }
            else {
                $YearSpecified = $true
            }

            # allowing 13 to be specified for Asian Lunar calendars.
            if ($Month -in 1..13) {
                [Int]$MonthNumber = $Month
            }
            # trailing 'f' means month specified, but next year required
            elseif ($Month -match '^(0?[1-9]|1[0-3])[Ff]$') {
                [Int]$MonthNumber = ($Month | Select-String -Pattern '^\d+').Matches.Value
                $Year += 1
            }
            # trailing 'p' means month specified, but last year required
            elseif ($Month -match '^(0?[1-9]|1[0-3])[Pp]$') {
                [Int]$MonthNumber = ($Month | Select-String -Pattern '^\d+').Matches.Value
                $Year -= 1
            }
            else {
                Write-Error "'$Month' is not a valid month number"
                return
            }
            <#
                add additional month before and after required month. This is better than Linux ncal. It allows
                a month in any year to be specified with -three. Linux ncal just ignores -3 and displays the 
                specified year.
            #>
            if ($true -eq $Three) {
                [Int]$BeforeOffset = 1
                [Int]$AfterOffset = 1
            }
        }
        else {
            # No month
            if (0 -eq $Year) {
                # Default is this month only
                $MonthNumber = $Now.Month
                $Year = $Now.Year
                $YearSpecified = $false
                # Add and additional month before and after this month.
                if ($true -eq $Three) {
                    [Int]$BeforeOffset = 1
                    [Int]$AfterOffset = 1
                }
            }
            else {
                # Year specified with no month; showing whole year.
                [Int]$MonthNumber = 1
                [Int]$BeforeOffset = 0
                [Int]$AfterOffset = ($Calendar.GetMonthsInYear($Year) - 1)
                $YearSpecified = $true
                # If we allow -year and -three (with no -month) then we get the first month of specified year with 
                # the month before and after. This feels like a bug, so ignore -three in this case.
                if ($true -eq $Three) {
                    Write-Warning 'The Three parameter is ignored when Year is specified with no Month.'
                }
            }
        }

        # add/remove specified number of months before the month(s) or year already identified
        $BeforeOffset += $Before
        $AfterOffset += $After

        <#
            Parameter validation complete. We have the required months to show, and a target month (typically this
            month or possibly first month of required year). Get the date object of the first day of the specified
            month and then use this to determine the date object of the first day of the first required month.
        #>
        $MonthCount = 1 + $BeforeOffset + $AfterOffset
        try {
            # Convert specified date to a date object. From this get the first required date object.
            $TargetDate = $Calendar.ToDateTime($Year, $MonthNumber, 1, 0, 0, 0, 0, $Calendar.Eras[0])
            $FirstDay = $Calendar.AddMonths($TargetDate, - $BeforeOffset)
        }
        catch {
            if (13 -eq $MonthNumber -and $PSItem.Exception.Message -match 'un-representable DateTime') {
                Write-Error 'Month must be between one and twelve. The specified calendar does not support month 13.'
            }
            else {
                $Msg = $PSItem.Exception.Message -replace 'Exception calling "ToDateTime" with "8" argument\(s\): ', ''
                Write-Error $Msg
            }
            return
        }

        for ($i = 1; $i -le $MonthCount; $i++) {
            $ThisYear = $Calendar.GetYear($FirstDay)
            $ThisMonth = $Calendar.GetMonth($FirstDay)
            $DayPerMonth = $Calendar.GetDaysInMonth($ThisYear, $ThisMonth)
            $MonthPerYear = $Calendar.GetMonthsInYear($ThisYear)
            [pscustomobject] @{
                'Date'          = $FirstDay # illustrates funky looking date when shown in local culture
                'Year'          = $ThisYear
                'Month'         = $ThisMonth
                'Day'           = $Calendar.GetDayOfMonth($FirstDay) # for clarity, not used
                'FirstDay'      = $Calendar.GetDayOfWeek($FirstDay) # for clarity, not used
                'FirstDayIndex' = $Calendar.GetDayOfWeek($FirstDay).value__ # e.g. Sunday=0..Starday=6.
                'DayPerMonth'   = $DayPerMonth # Not used
                'PrintMonth'    = $i # used to determine partial years with -Year
                'MonthPerYear'  = $MonthPerYear
                'YearSpecified' = $YearSpecified # Used to determine year and month headings
            }
            $FirstDay = $Calendar.AddMonths($FirstDay, 1)
        }
    } #end process
}