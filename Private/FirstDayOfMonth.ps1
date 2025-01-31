#Requires -Version 7.2 

function Get-FirstDayOfMonth {
    <# 
        .NOTES
        Helper function for Get-NCalendar and Get-Calendar that returns the date and day name of the first day of each 
        required month, using the specified culture. This function performs the paramters validation for both ncal and
        cal.

        Note to self - the thing to remember when using different cultures is that once you've determined the
        correct date in the required culture, you parse this to create a date object. Because we're not messing 
        with the default system culture here, the date objects returned by this function will appear in the local 
        culture. So non-Gregorian culture dates, like Persian, will look funky.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Globalization.CultureInfo]$Culture,
        
        # Could be an integer between 1 and 12 or same with an f or p suffix
        [Parameter(Position = 1)]
        [String]$Month,
        
        [Parameter(Position = 2)]
        [ValidateRange(1000, 9999)]
        [Int]$Year,

        [Parameter(Position = 3)]
        [Int]$Before,
        
        [Parameter(Position = 4)]
        [Int]$After,

        [Parameter(Position = 5)]
        [Switch]$Three
    )

    process {
        # Todays date in specified culture
        $Now = Get-Today -Culture $Culture

        if ($PSBoundParameters.ContainsKey('Month')) {
            [Int]$AfterOffset = 0

            if ($PSBoundParameters.ContainsKey('Year')) { 
                $YearSpecified = $true
            }
            else {
                $Year = $Now.Year
                $YearSpecified = $false
            }

            if ($Month -in 1..12) {
                [Int]$MonthNumber = $Month
            }
            # trailing 'f' means month specified, but next year required
            elseif ($Month -match '^(0?[1-9]|1[0-2])[Ff]$') {
                [Int]$MonthNumber = ($Month | Select-String -Pattern '^\d+').Matches.Value
                $Year += 1
            }
            # trailing 'p' means month specified, but last year required
            elseif ($Month -match '^(0?[1-9]|1[0-2])[Pp]$') {
                [Int]$MonthNumber = ($Month | Select-String -Pattern '^\d+').Matches.Value
                $Year -= 1
            }
            else {
                Write-Error "ncal: '$Month' is neither a month number (1..12) nor a valid month name (using the current culture)"
                return
            }
        }
        else {
            # No month
            if ($PSBoundParameters.ContainsKey('Year')) {
                # Year specified with no month; showing whole year
                [Int]$MonthNumber = 1
                [Int]$BeforeOffset = 0
                [Int]$AfterOffset = 11
                $YearSpecified = $true
            }
            else {
                # Default is this month only
                $MonthNumber = $Now.Month
                $Year = $Now.Year
                $YearSpecified = $false
            }
        }

        # add additional month before and after current month.
        if ($PSBoundParameters.ContainsKey('Three')) {
            [Int]$BeforeOffset = 1
            [Int]$AfterOffset = 1
        }
        # add specified number of months before the month or year already identified
        if ($PSBoundParameters.ContainsKey('Before')) {
            $BeforeOffset += $Before
        }
        # add specified number of months following the month(s) or year already identified
        if ($PSBoundParameters.ContainsKey('After')) {
            $AfterOffset += $After
        }

        # special case for ar-sa (Arabic, Saudi Arabia)
        if ($Culture.Name -match '^(ar-SA)$' -and ($Year -lt 1318 -or $Year -gt 1500)) {
            write-verbose $Year
            Write-Error 'The UmAlQura calendar (Saudi Arabia) is only supported for years 1318 to 1500.'
            return
        }

        # Parameter validation complete. We have the required months to show, and a target month (typically this
        # month or possibly first month of required year). Determine the date of the first day of target month
        # and then use this to determine the date of the first day of the first required month.
        $MonthCount = 1 + $BeforeOffset + $AfterOffset
        $DateString = '{0}/{1:D2}/{2}' -f '01', $MonthNumber, $Year # ParseExact expects 2 digit day and month
        $TargetDate = [datetime]::ParseExact($DateString, 'dd/MM/yyyy', $Culture)
        $FirstDay = $Culture.Calendar.AddMonths($TargetDate, - $BeforeOffset)
    
        for ($i = 1; $i -le $MonthCount; $i++) {
            $ThisYear = $Culture.Calendar.GetYear($FirstDay)
            $ThisMonth = $Culture.Calendar.GetMonth($FirstDay)
            $DayPerMonth = $Culture.Calendar.GetDaysInMonth($ThisYear, $ThisMonth)
            [pscustomobject] @{
                'Date'          = $FirstDay # illustrates funky looking date when shown in local culture
                'Year'          = $ThisYear
                'Month'         = $ThisMonth
                'Day'           = $Culture.Calendar.GetDayOfMonth($FirstDay) # for clarity, not used
                'FirstDay'      = $Culture.Calendar.GetDayOfWeek($FirstDay) # for clarity, not used
                'FirstDayIndex' = $Culture.Calendar.GetDayOfWeek($FirstDay).value__ # Monday=1, Sunday=7
                'DayPerMonth'   = $DayPerMonth
                'YearSpecified' = $YearSpecified # Used to determine year and month headings
            }
            $FirstDay = $Culture.Calendar.AddMonths($FirstDay, 1)
        }
    }
}