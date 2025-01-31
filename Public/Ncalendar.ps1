#Requires -Version 7.2 

function Get-NCalendar {
    <#
    .SYNOPSIS
        Get-NCalendar
    .DESCRIPTION
        This command displays calendar information similar to the Linux ncal command. It implements most of the
        same functionality, including the ability to display multiple months, years, week numbers, day of the year 
        and month forward and previous by one year.

        But in addition, the command can do a whole lot more:
        1. Display a calendar in any supported culture. Month and day names are displayed in the chosen culture, 
           and using the primary calendar used for each culture.
        2. Start of week can be selected (Friday through Monday). By default, the culture setting is used.
        3. Display abbreviated (default) or full day names, specific to the culture.
        4. Display one to six months in a row, when multiple months are displayed (the default is 4).
        5. When display week numbers, they will align correctly with the first day of the week.
        6. Highlighting the month headings, today and week numbers is possible.
        
        It is highly recommended that Windows Terminal is used with an appropriate font to ensure that ISO unicode
        character sets are both available and display properly. With one or two exceptions, all cultures align 
        correctly.

        Currently, 'Optional' calendars are not supported. These include the Julian, Hijra (Islamic), Chinese Lunar, 
        Hebrew and several other calendars which are not used primarily by any culture but are observed in many parts
        of the world for religious or scientific purposes.
    .PARAMETER Month
        Specifies the required month. This must be specified as a number 0..12. An 'f' (forward by one year) or a 'p' 
        (previous year) suffix can also be appended to the month number.
    .PARAMETER Year
        Specifies the required year. If no month is specified, the whole year is shown.
    .PARAMETER Culture
        Specifies the required culture. The system default culture is used by default.
    .PARAMETER FirstDayOfWeek
        Display the specified first day of the week. By default, the required culture is used to determine this.
    .PARAMETER MonthPerRow
        Display the specified number of months in each row. By default it is 4 months.
    .PARAMETER Highlight
        By default, today's date is highlighted. Specify a colour or disable the default highlight with 'none'.
    .PARAMETER Before
        The specified number of months are added before the specified month(s). See -After for examples.
    .PARAMETER After
        The specified number of months are added after the specified month(s). This is in addition to any date range 
        selected by the -Year or -Three options. For example, ncal -y 2021 -B 2 -A 2 will show from November 2020 to
        February 2022. Negative numbers are allowed, in which case the specified number of months is subtracted. For
        example, ncal -Y 2021 -B -6 shows July to December. Another example, ncal -A 11 simply shows the next 12 months.
    .PARAMETER Three
        Display the previous, current and next month surrounding the requested month. If -Year is also specified, this 
        parameter is ignored.
    .PARAMETER DayOfYear
        Display the day of the year (days one-based, numbered from 1st January).
    .PARAMETER Week
        Print the number of the week below each week column
    .PARAMETER LongDayName
        Display full day names for the required culture, instead of abbreviated day names.
    .EXAMPLE
        PS C:\> ncal
        
        Displays this month
    .EXAMPLE
        PS C:\> cal -m 1 -a 11
        
        Displays this year in any culture. for example, -y 2025 with cultures that do not use the Gregorian calendar
        by default will not work or produce unintended results. Some cultures use the Persian (Iranian), ThaiBuddist 
        and UmAlQura (Umm al-Qura, Saudi Arabian) calendars by default.
    .EXAMPLE
        PS C:\> ncal -m 1f

        Displays January next year. -m 1p shows January from the previous year
    .EXAMPLE
        PS C:\> ncal -m 4 -y 2021 -b 2 -a 1

        Displays April 2021 with the two months before and the month after it.
    .EXAMPLE
        PS C:\> ncal -y 2021 -a 24
        
        Shows 2021 through 2023
    .EXAMPLE
        PS C:\> ncal -j -three
        
        Show Julian days for last month, this month and next month
    .EXAMPLE
        PS C:\> ncal 2 2022 -three 
        
        Show February 2022 together with the month prior and month after.
    .EXAMPLE
        PS C:> ncal -Y 2021 -Highlight Red

        Shows the specified year with a highlighted colour. Supports red, blue, 
        green, yellow, orange, cyan, magenta and white. Disable all highlighting with 'none'.
    .INPUTS
        [System.String]
        [System.Int]
    .OUTPUTS
        [System.String]
    .NOTES
        Author: Roy Atkins
    #>
    [Alias('ncal')]
    [CmdletBinding()]
    param(
        # Could be integer between 1 and 12 or the same with an 'f' or 'p' suffix.
        [Parameter(Position = 0)]
        [Alias('m')]
        [String]$Month,

        [Parameter(Position = 1)]
        [ValidateRange(1000, 9999)]
        [Int]$Year,

        [Parameter(Position = 2)]
        [String]$Culture,

        [Parameter(Position = 3)]
        [ValidateSet('Friday', 'Saturday', 'Sunday', 'Monday')]
        [String]$FirstDayOfWeek,

        [Parameter(Position = 4)]
        [ValidateRange(1, 6)]
        [Int]$MonthPerRow = 4,

        [Parameter(Position = 5)]
        [ValidateSet('None', 'Red', 'Green', 'Blue', 'Yellow', 'Cyan', 'Magenta', 'White', 'Orange')]
        [String]$Highlight,

        [Int]$Before,

        [Int]$After,

        [Switch]$Three,

        [Switch]$DayOfYear,

        [Switch]$Week,

        [Switch]$LongDayName
    )

    begin {
        $Abort = $false
        if ($PSBoundParameters.ContainsKey('Culture')) {
            #$ThisCulture = [System.Globalization.CultureInfo]::CreateSpecificCulture($Culture)
            try {
                $ThisCulture = New-Object System.Globalization.CultureInfo($Culture) -ErrorAction Stop
            }
            catch {
                Write-Warning "ncal: Invalid culture specified:'$Culture'. Using the system default culture ($((Get-Culture).Name)). Use 'Get-Culture -ListAvailable'."
                $ThisCulture = [System.Globalization.CultureInfo]::CurrentCulture
            }
        }
        else {
            $ThisCulture = [System.Globalization.CultureInfo]::CurrentCulture
        }

        # Full month names in current culture
        $MonthNameArray = $ThisCulture.DateTimeFormat.MonthGenitiveNames

        <# 
            Instead of showing days of month, show days of the year. Linux ncal is wrong in referring to this as
            Julian Day, which is a continuous count of days from the start of the Julian Period (current Julian 
            Period started in 4713 BC). However, continue to use "Julian" because its more eye-catching than
            "DayOfYear".
        #>
        if ($PSBoundParameters.ContainsKey('DayOfYear')) {
            [Bool]$JulianSpecified = $true
        }
        else {
            [Bool]$JulianSpecified = $false
        }

        # List of abbreviated or long day names in the required order.
        if ($PSBoundParameters.ContainsKey('FirstDayOfWeek')) {
            $Param = @{
                'Culture'        = $ThisCulture
                'FirstDayOfWeek' = $FirstDayOfWeek
                'LongDayName'    = $LongDayName
            }
            $WeekDay = Get-WeekDayName @Param
        }
        else {
            $DefaultFirstDay = $ThisCulture.DateTimeFormat.FirstDayOfWeek
            $Param = @{
                'Culture'        = $ThisCulture
                'FirstDayOfWeek' = $DefaultFirstDay
                'LongDayName'    = $LongDayName
            }
            $WeekDay = Get-WeekDayName @Param
        }

        # Get the date of the first day of each required month, based on the culture (common to ncal & cal)
        $DateParam = New-Object -TypeName System.Collections.Hashtable
        $DateParam.Add('Culture', $ThisCulture)
        if ($PSBoundParameters.ContainsKey('Month')) {
            $DateParam.Add('Month', $Month)
        }
        if ($PSBoundParameters.ContainsKey('Year')) {
            $DateParam.Add('Year', $Year)
        }
        if ($PSBoundParameters.ContainsKey('Three')) {
            $DateParam.Add('Three', $Three)
        }
        if ($PSBoundParameters.ContainsKey('Before')) {
            $DateParam.Add('Before', $Before)
        }
        if ($PSBoundParameters.ContainsKey('After')) {
            $DateParam.Add('After', $After)
        }
        # this is where most parameter validation occurs, and most of the date conversion stuff.
        try {
            $MonthList = Get-FirstDayOfMonth @DateParam -ErrorAction Stop
        }
        catch {
            Write-Error $PSItem.Exception.Message
            $Abort = $true
        }

        # To hold each row of 1 to 6 months, initialized with culture specific day abbreviation
        [System.Collections.Generic.List[String]]$MonthRow = $WeekDay.Name
        $MonthCount = 0
        $MonthHeading = ' ' * $WeekDay.Offset
        $WeekRow = ' ' * ($WeekDay.Offset - 1)
    }
    process {
        foreach ($RequiredMonth in $MonthList) {
            if ($true -eq $Abort) {
                return
            }
            $ThisYear = $RequiredMonth.Year
            $ThisMonth = $RequiredMonth.Month
            $DayPerMonth = $RequiredMonth.DayPerMonth
            $FirstDayIndex = $RequiredMonth.FirstDayIndex
            $YearSpecified = $RequiredMonth.YearSpecified
            $MonthName = $MonthNameArray[$ThisMonth - 1]  # MonthNameArray is zero based
            if ($PSBoundParameters.ContainsKey('Three') -or $PSBoundParameters.ContainsKey('Month') -or $false -eq $YearSpecified) {
                $MonthName = "$MonthName $ThisYear"
            }

            # for highlighting today
            $Pretty = Get-Highlight $ThisCulture $ThisMonth $ThisYear $Highlight
            Write-Verbose "monthname = $MonthName, thismonth = $ThisMonth, thisyear = $ThisYear, dayspermonth = $DayPerMonth, monthcount = $MonthCount, culture = $($ThisCulture.Name)"

            # User specified First day of the week, or use the default for the culture being used.
            if ($PSBoundParameters.ContainsKey('FirstDayOfWeek')) {
                if ('Friday' -eq $FirstDayOfWeek) {
                    $StartWeekDay = 'Friday'
                }
                elseif ('Saturday' -eq $FirstDayOfWeek) {
                    $StartWeekDay = 'Saturday'
                }
                elseif ('Sunday' -eq $FirstDayOfWeek) {
                    $StartWeekDay = 'Sunday'
                }
                else {
                    $StartWeekDay = 'Monday'
                }
            }
            else {
                $StartWeekDay = $ThisCulture.DateTimeFormat.FirstDayOfWeek
            }

            # Get the starting index for the month, to offset when to start printing dates in the row.
            $Param = @{
                'Culture'       = $ThisCulture
                'StartWeekDay'  = $StartWeekDay
                'FirstDayIndex' = $FirstDayIndex
            }
            $ThisIndex = Get-StartWeekIndex @Param

            # User can choose number of months to print per row, default is 4. In this case, just append the month.
            if ($MonthCount -lt $MonthPerRow) {
                $Param = @{
                    'Culture'         = $ThisCulture
                    'MonthName'       = $MonthName
                    'JulianSpecified' = $JulianSpecified
                }
                $MonthHeading += "$(Get-MonthHeading @Param)"
                if ($PSBoundParameters.ContainsKey('Week')) {
                    $Param = @{
                        'Culture'         = $ThisCulture
                        'Month'           = $ThisMonth
                        'Year'            = $ThisYear
                        'FirstDayOfWeek'  = $StartWeekDay
                        'Index'           = $ThisIndex
                        'JulianSpecified' = $JulianSpecified
                    }
                    $WeekRow += Get-WeekRow @Param
                }
            }
            else {
                # Print a year heading before January when year is specified when the year is not already in month name
                if ($MonthHeading -match "\b$($MonthNameArray[0])\b" -and $MonthName -notmatch $ThisYear) {
                    $YearPad = (((18 * $MonthPerRow) + 3 - 2 ) / 2) + 2 
                    $YearHeading = "$ThisYear".PadLeft($YearPad, ' ')
                    Write-Output "$($Pretty.MonStyle)$YearHeading$($Pretty.MonReset)"
                }
                Write-Output "$($Pretty.MonStyle)$MonthHeading$($Pretty.MonReset)"
                Write-Output $MonthRow
                if ($PSBoundParameters.ContainsKey('Week')) {
                    Write-Output "$($Pretty.MonStyle)$WeekRow$($Pretty.MonReset)"
                }
                Write-Output ''

                # Reset for next row of months
                [System.Collections.Generic.List[String]]$MonthRow = $WeekDay.Name
                $MonthCount = 0
                $Param = @{
                    'Culture'         = $ThisCulture
                    'MonthName'       = $MonthName
                    'JulianSpecified' = $JulianSpecified
                }
                $MonthHeading = (' ' * $WeekDay.Offset) + "$(Get-MonthHeading @Param)"
                if ($PSBoundParameters.ContainsKey('Week')) {
                    $Param = @{
                        'Culture'         = $ThisCulture
                        'Month'           = $ThisMonth
                        'Year'            = $ThisYear
                        'FirstDayOfWeek'  = $StartWeekDay
                        'Index'           = $ThisIndex
                        'JulianSpecified' = $JulianSpecified
                    }
                    $WeekRow = Get-WeekRow @Param
                    
                    # starting padding for the week row is dependent on first week number
                    if (1 -eq "$WeekRow".Split(' ')[0].Length) {
                        $WeekRow = (' ' * $WeekDay.Offset) + $WeekRow
                    }
                    else {
                        $WeekRow = (' ' * ($WeekDay.Offset - 1)) + $WeekRow
                    }
                }
            }

            0..6 | ForEach-Object {
                $Param = @{
                    'Culture'         = $ThisCulture
                    'Index'           = $ThisIndex
                    'DayPerMonth'     = $DayPerMonth
                    'Month'           = $ThisMonth
                    'Year'            = $ThisYear
                    'Highlight'       = $Pretty
                    'JulianSpecified' = $JulianSpecified
                }
                $MonthRow[$_] += "$(Get-NcalRow @Param)"
                $ThisIndex++
            }
            $MonthCount++
        }
    }
    end {
        # Write the last month or row of months
        # Print a year heading before January when there is no year already in the month name.
        if (-Not $Abort) {
            if ($MonthHeading -match "\b$($MonthNameArray[0])\b" -and $MonthName -notmatch $ThisYear) {
                $YearPad = (((18 * $MonthPerRow) + 3 - 2 ) / 2) + 2 
                $YearHeading = "$ThisYear".PadLeft($YearPad, ' ')
                Write-Output "$($Pretty.MonStyle)$YearHeading$($Pretty.MonReset)"
            }
            Write-Output "$($Pretty.MonStyle)$MonthHeading$($Pretty.MonReset)"
            Write-Output $MonthRow
            if ($PSBoundParameters.ContainsKey('Week')) {
                Write-Output "$($Pretty.MonStyle)$WeekRow$($Pretty.MonReset)"
            }
        }
    }
}
