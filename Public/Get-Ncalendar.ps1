#Requires -Version 7.2 
function Get-NCalendar {
    <#
    .SYNOPSIS
        Get-NCalendar
    .DESCRIPTION
        This command displays calendar information similar to the Linux ncal command. It implements the same 
        functionality, including the ability to display multiple months, years, week number per year, day of the
        year and month forward and month previous by one year.

        But in addition, the command can do a whole lot more:
        1. Display a calendar in any supported culture. Month and day names are displayed in the appropriate
        language for the specified culture and the appropriate calendar is used (e.g. Gregorian, Persian), along
        with appropriate DateTimeFormat information (e.g. default first day of the week).
        2. As well as display the primary calendar (used by each culture), also display optional calendars.
        These are Hijri, Hebrew, Japanese (Solar), Korean (Solar) and Taiwanese (Solar) calendars. In addition,
        the non-optional calendars (i.e. calendars not used by any culture, but still observed for religious, 
        scientific or traditional purposes). These are the Julian and Chinese, Japanese, Korean and Taiwanese Lunar
        calendars. (Note: Only the current era is supported).
        3. Specify the first day of the week (Friday through Monday). The specified or current culture setting is 
        used by default. Friday through Monday are supported because all cultures use one of these days.
        4. Display abbreviated (default) or full day names, specific to the culture.
        5. Display one to six months in a row, when multiple months are displayed (the default is 4).
        6. When displaying week numbers, they will align correctly with respect to the default or specified first
        day of the week.
        7. Highlight the year and month headings, todays date and week numbers using a specified colour.

        It is highly recommended that Windows Terminal is used with an appropriate font to ensure that ISO unicode
        character sets are both available and are displayed correctly. With other consoles, like Visual Studio Code,
        the ISE and the default PowerShell console, some fonts might not display correctly and with extended unicode
        character sets, calendars may appear misaligned.

        Note: From version 1.22.10352.0 (Feb 2025) of Windows Terminal, grapheme clusters are now supported and are 
        turned on by default. A grapheme cluster is a single user-perceived character made up of multiple code 
        points from the Unicode Standard, introduced in .NET 5. Whilst this is considered the correct method for 
        handling and displaying Unicode character sets, PowerShell doesn't support grapheme clusters and thus, 
        calandars in ncal appear misaligned. This can be remedied, in the short term, by disabling grapheme cluster 
        support in Settings > Compatibility > Text measurement mode, selecting "Windows Console" and then 
        restarting the Windows Terminal.
    .PARAMETER Month
        Specifies the required month. This must be specified as a number 0..13. An 'f' (forward by one year) or a
        'p' (previous by one year) suffix can also be appended to the month number.
    .PARAMETER Year
        Specifies the required year. If no month is specified, the whole year is shown.
    .PARAMETER Culture
        Specifies the required culture. The system default culture is used by default.
    .PARAMETER Calendar
        Instead of a culture, specify a calendar. This allows displaying optional and other calendars not used
        by any culture. They include Julian, Hijri, Hebrew and Chinese Lunar calendars.
    .PARAMETER FirstDayOfWeek
        Display the specified first day of the week. By default, the required culture is used to determine this.
    .PARAMETER MonthPerRow
        Display the specified number of months in each row. By default it is 4 months.
    .PARAMETER Highlight
        By default, today's date is highlighted. Specify a colour to highlight today, the year/month headings and
        week numbers or disable the default highlight with 'none'.
    .PARAMETER Before
        The specified number of months are added before the specified month(s). See -After for examples.
    .PARAMETER After
        The specified number of months are added after the specified month(s), i.e. in addition to any date range 
        selected by the -Year or -Three options. Negative numbers are allowed, in which case the specified number 
        of months is subtracted. For example ncal -after 11 simply shows the next 12 months in any culture.
    .PARAMETER Three
        Display the current month together with the previous and following month. This is ignored if -Year is also 
        specified without a month.
    .PARAMETER DayOfYear
        Display the day of the year (days one-based, numbered from 1st January).
    .PARAMETER Week
        Display the number of the week below each week column.
    .PARAMETER LongDayName
        Display full day names for the required culture or calendar, instead of abbreviated day names (default).
        For some cultures, there is no difference.
    .PARAMETER Name
        Display the name of the specified culture and/or calendar name as a banner above the calendar.
    .EXAMPLE
        PS C:\> ncal
        
        Displays this month using the current culture
    .EXAMPLE
        PS C:\> ncal -month 1 -after 11 -culture fa
        
        Displays the first month and the following 11 months (this year) for any specified culture. For example, 
        -Year 2025 with cultures that do not use the Gregorian calendar by default will not work or produce 
        unintended results. Some cultures use the Persian (Iranian), ThaiBuddist and UmAlQura (Umm al-Qura, Saudi 
        Arabian) calendars by default.
    .EXAMPLE
        PS C:\> ncal -m 1f

        Displays January next year. -m 4p shows April from the previous year
    .EXAMPLE
        PS C:\> ncal -m 4 -y 2025 -b 2 -a 1

        Displays April 2025 with the two months before and one month after it.
    .EXAMPLE
        PS C:\> ncal -y 2025 -a 24
        
        Shows 2025 through 2027
    .EXAMPLE
        PS C:\> ncal -DayOfYear -three
        
        Show the day number, starting from 1st January, for this month as well as last month and next month.
    .EXAMPLE
        PS C:\> ncal 2 2026 -three 
        
        Show February 2026 with the month prior and month after.
    .EXAMPLE
        PS C:> ncal -Year 2025 -Week -H Cyan

        Shows the specified year with a highlighted colour. Supports red, blue, 
        green, yellow, orange, pink, cyan, magenta and white. Disable all highlighting with - Highlight 'none'. Week
        numbers are shown below each week column and are also highlighted.
    .EXAMPLE
        PS C:> ncal -culture ja-JP -Year 2025 -Highlight Orange

        Display a calender using the  Japanese (Japan) culture for the specified year.
    .EXAMPLE
        PS C:> 'Persian','Hijri','UmAlQura' | % { ncal -calendar $_ -name }

        Display three calendars (the current month) using the specified calendars with a banner to identify each 
        culture/calendar.
    .EXAMPLE
        PC C:> 'en-au','en-us','dv','mzn' | % { ncal -c $_ -Name -Week -Highlight Yellow }

        Display calendars for the specified cultures. This example illustrates the different DateTimeFormat 
        information for each culture (different start days for the week).
    .EXAMPLE
        PS C:> ncal -calendar Julian -m 1 -a 11

        Shows this year in the Julian calendar.
        
        Note: This actually works correctly, unlike the Linux ncal command (as at Feb 2025), which sometimes shows
        the wrong month (shows this Julian month but in terms of month number on the Gregorian calendar),
        depending on the day of the month.
    .EXAMPLE
        PS C:> ncal -cal Hijri -m 1 -a 11

        Shows this year in the Hijri (Muslim) calendar.

        Note: This is not supported with Linux ncal command.
    .LINK
        https://github.com/atkinsroy/ncal/docs
    .INPUTS
        [System.String]
        [System.Int]
    .OUTPUTS
        [System.String]
    .NOTES
        Author: Roy Atkins
    #>
    [Alias('ncal')]
    [CmdletBinding(DefaultParameterSetName = 'UseCulture')]
    param(
        # Could be integer between 1 and 13 or the same with an 'f' or 'p' suffix.
        [Parameter(Position = 0)]
        [Alias('m')]
        [ValidatePattern('^(0?[1-9]|1[0-3])([FfPp])?$')]
        [String]$Month,

        [Parameter(Position = 1)]
        [ValidateRange(1, 9999)]
        [Int]$Year,

        [Parameter(Position = 2, ParameterSetName = 'UseCulture')]
        [Alias('c', 'cul')]
        [String]$Culture,

        [Parameter(Position = 2, ParameterSetName = 'UseCalendar')]
        [Alias('cal')]
        [ValidateSet(
            'Gregorian', 
            'Persian', 
            'Hijri', 
            'Hebrew', 
            'Japanese', 
            'Korean', 
            'Taiwan', 
            'UmAlQura', 
            'ThaiBuddhist',
            'Julian',
            'ChineseLunisolar',
            'JapaneseLunisolar',
            'KoreanLunisolar',
            'TaiwanLunisolar')]
        [String]$Calendar,

        [Parameter(Position = 3)]
        [ValidateSet('Friday', 'Saturday', 'Sunday', 'Monday')]
        [String]$FirstDayOfWeek,

        [Parameter(Position = 4)]
        [Alias('r', 'row')]
        [ValidateRange(1, 6)]
        [Int]$MonthPerRow = 4,

        [Parameter(Position = 5)]
        [ValidateSet('None', 'Red', 'Green', 'Blue', 'Yellow', 'Cyan', 'Magenta', 'White', 'Orange', 'Pink')]
        [String]$Highlight,

        [Int]$Before,

        [Int]$After,

        [Switch]$Three,

        [Switch]$DayOfYear,

        [Switch]$Week,

        [Switch]$LongDayName,

        [switch]$Name
    )

    begin {
        $Globalization = Get-Globalization -Calendar $Calendar -Culture $Culture
        $ThisCulture = $Globalization.Culture
        $ThisCalendar = $Globalization.Calendar
        $IgnoreWeekRow = $Globalization.IgnoreWeekRow

        # User has specified a calendar with -Week that doesn't support week rows.
        if ($PSBoundParameters.ContainsKey('Week') -and $true -eq $IgnoreWeekRow) {
            Write-Warning "Displaying week numbers is not supported with the $($ThisCalendar.ToString().Replace('System.Globalization.', '').Replace('Calendar',' calendar.'))"
        }

        # Display the Culture/Calendar name as a heading
        if ($PSBoundParameters.ContainsKey('Name')) {
            Write-Globalization -Culture $ThisCulture -Calendar $ThisCalendar
        }

        # Full month names in current culture
        $MonthNameArray = $ThisCulture.DateTimeFormat.MonthGenitiveNames

        # Use specified first day of the week or default for the culture
        if ($PSBoundParameters.ContainsKey('FirstDayOfWeek')) {
            $FirstDay = $FirstDayOfWeek
        }
        else {
            $FirstDay = $ThisCulture.DateTimeFormat.FirstDayOfWeek
        }

        # Get a list of weekday names. Either abbreviated (default) or full day names. Some cultures are messed
        # with to get best formatting results. 
        $Param = @{
            'Culture'         = $ThisCulture
            'FirstDayOfWeek'  = $FirstDay
            'JulianSpecified' = $DayOfYear
            'LongDayName'     = $LongDayName
            'Mode'            = 'Get-NCalendar'
        }
        $WeekDay = Get-WeekDayName @Param

        # Get the date of the first day of each required month, based on the culture.
        # This is where most parameter validation occurs, and most of the date conversion stuff.
        try {
            $DateParam = @{
                'Calendar' = $ThisCalendar
                'Month'    = $Month
                'Year'     = $Year
                'Before'   = $Before
                'After'    = $After
                'Three'    = $Three
            }
            $MonthList = Get-FirstDayOfMonth @DateParam -ErrorAction Stop
        }
        catch {
            Write-Error $PSItem.Exception.Message -ErrorAction Stop
        }

        # To hold each row of 1 to 6 months, initialized with culture specific day abbreviation
        [System.Collections.Generic.List[String]]$MonthRow = $WeekDay.Name
        $MonthCount = 0
        $MonthHeading = ' ' * $WeekDay.Offset
        $WeekRow = ' ' * ($WeekDay.Offset - 1)
    }

    process {
        foreach ($RequiredMonth in $MonthList) {
            $ThisYear = $RequiredMonth.Year
            $ThisMonth = $RequiredMonth.Month
            $DayPerMonth = $RequiredMonth.DayPerMonth
            $PrintMonth = $RequiredMonth.PrintMonth # don't print Zodiac animal for initial partial year
            $FirstDayIndex = $RequiredMonth.FirstDayIndex
            $YearSpecified = $RequiredMonth.YearSpecified
            $MonthName = $MonthNameArray[$ThisMonth - 1]  # MonthNameArray is zero based
            if (13 -eq $ThisMonth) {
                $MonthName = switch ($Calendar) {  
                    'JapaneseLunisolar' { '閏月'; break }
                    'KoreanLunisolar' { '윤달'; break }
                    default { '闰月' } # Chinese and Taiwan Lunar calendars
                }
            }
            # Month name contains year when -Year is not specified.
            if ($PSBoundParameters.ContainsKey('Three') -or $PSBoundParameters.ContainsKey('Month') -or $false -eq $YearSpecified) {
                $MonthName = "$MonthName $ThisYear"
            }

            # Highlight today
            $Pretty = Get-Highlight $ThisCalendar $ThisMonth $ThisYear $Highlight

            # Print some useful verbose information for debugging and testing purposes.
            if ($PSBoundParameters.ContainsKey('Calendar')) {
                Write-Verbose "monthname = $MonthName, thismonth = $ThisMonth, thisyear = $ThisYear, dayspermonth = $DayPerMonth, monthcount = $MonthCount, printmonth = $PrintMonth, calendar = $($ThisCalendar.ToString().Replace('System.Globalization.', '')), era = $($ThisCalendar.Eras[0])"
            }
            else {
                Write-Verbose "monthname = $MonthName, thismonth = $ThisMonth, thisyear = $ThisYear, dayspermonth = $DayPerMonth, monthcount = $MonthCount, printmonth = $PrintMonth, culture = $($ThisCulture.Name)"
            }

            # Get the starting index for the month, to offset when to start printing dates in the row.
            $Param = @{
                'StartWeekDay'  = $FirstDay
                'FirstDayIndex' = $FirstDayIndex
            }
            $ThisIndex = Get-StartWeekIndex @Param

            # Special case when January is encountered and -Year is specified. We want to print the remaining
            # months of the current row to align the year heading.
            if ($PSBoundParameters.ContainsKey('Year') -and $ThisMonth -eq 1 -and $MonthCount -gt 0) {
                Write-Verbose 'Print last row of months for a year when -Year is specified to preserve alignment of year headings'
                Write-Output "$($Pretty.MonStyle)$MonthHeading$($Pretty.MonReset)"
                Write-Output $MonthRow
                if ($PSBoundParameters.ContainsKey('Week') -and -not $IgnoreWeekRow) {
                    Write-Output "$($Pretty.MonStyle)$WeekRow$($Pretty.MonReset)"
                }
                Write-Output ''

                # Reset for next row of months
                [System.Collections.Generic.List[String]]$MonthRow = $WeekDay.Name
                $MonthCount = 0
                $Param = @{
                    'Culture'         = $ThisCulture
                    'MonthName'       = $MonthName
                    'JulianSpecified' = $DayOfYear
                    'Mode'            = 'Get-NCalendar'
                }
                $MonthHeading = (' ' * $WeekDay.Offset) + "$(Get-MonthHeading @Param)"
                
                if ($PSBoundParameters.ContainsKey('Week') -and -not $IgnoreWeekRow) {
                    $Param = @{
                        'Culture'         = $ThisCulture
                        'Calendar'        = $ThisCalendar
                        'Month'           = $ThisMonth
                        'Year'            = $ThisYear
                        'FirstDayOfWeek'  = $FirstDay
                        'Index'           = $ThisIndex
                        'JulianSpecified' = $DayOfYear
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
            elseif ($MonthCount -lt $MonthPerRow) {
                # Construct the calendar rows, based on the number months per row. default is 4, but can be
                # specified with -MonthPerRow. Also construct Week row string, if -Week is specified and supported
                # for this calendar.
                $Param = @{
                    'Culture'         = $ThisCulture
                    'MonthName'       = $MonthName
                    'JulianSpecified' = $DayOfYear
                    'Mode'            = 'Get-NCalendar'
                }
                $MonthHeading += "$(Get-MonthHeading @Param)"
                if ($PSBoundParameters.ContainsKey('Week') -and -not $IgnoreWeekRow) {
                    $Param = @{
                        'Culture'         = $ThisCulture
                        'Calendar'        = $ThisCalendar
                        'Month'           = $ThisMonth
                        'Year'            = $ThisYear
                        'FirstDayOfWeek'  = $FirstDay
                        'Index'           = $ThisIndex
                        'JulianSpecified' = $DayOfYear
                    }
                    $WeekRow += Get-WeekRow @Param
                }
            }
            else {
                # Print a year heading before January when year is specified and when the year is not already in month name
                Write-Verbose 'Print normal row of months'
                if ($PSBoundParameters.ContainsKey('Year') -and $MonthHeading -match "\b$($MonthNameArray[0])\b") {
                    # Print the Zodiac animal for the previous full year with lunar calendars.
                    $Previousmonth = $PrintMonth - (1 + $MonthPerRow)
                    if ($Calendar -match 'Lunisolar' -and $Previousmonth -ge 12) {
                        Write-ZodiacAnimal -Calendar $Calendar -Year ($ThisYear - 1) -Pretty $Pretty
                    }
                    $YearPad = (((18 * $MonthPerRow) + 3 - 2 ) / 2) + 2 
                    $YearHeading = "$ThisYear".PadLeft($YearPad, ' ')
                    Write-Output "$($Pretty.MonStyle)$YearHeading$($Pretty.MonReset)"
                }
                # Display current row of months
                Write-Output "$($Pretty.MonStyle)$MonthHeading$($Pretty.MonReset)"
                Write-Output $MonthRow
                if ($PSBoundParameters.ContainsKey('Week') -and -not $IgnoreWeekRow) {
                    Write-Output "$($Pretty.MonStyle)$WeekRow$($Pretty.MonReset)"
                }
                Write-Output ''

                # Reset for next row of months
                [System.Collections.Generic.List[String]]$MonthRow = $WeekDay.Name
                $MonthCount = 0
                $Param = @{
                    'Culture'         = $ThisCulture
                    'MonthName'       = $MonthName
                    'JulianSpecified' = $DayOfYear
                    'Mode'            = 'Get-NCalendar'
                }
                $MonthHeading = (' ' * $WeekDay.Offset) + "$(Get-MonthHeading @Param)"
                
                if ($PSBoundParameters.ContainsKey('Week') -and -not $IgnoreWeekRow) {
                    $Param = @{
                        'Culture'         = $ThisCulture
                        'Calendar'        = $ThisCalendar
                        'Month'           = $ThisMonth
                        'Year'            = $ThisYear
                        'FirstDayOfWeek'  = $FirstDay
                        'Index'           = $ThisIndex
                        'JulianSpecified' = $DayOfYear
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
                    'Calendar'        = $ThisCalendar
                    'Index'           = $ThisIndex
                    'DayPerMonth'     = $DayPerMonth
                    'Month'           = $ThisMonth
                    'Year'            = $ThisYear
                    'Highlight'       = $Pretty
                    'JulianSpecified' = $DayOfYear
                }
                $MonthRow[$_] += "$(Get-NcalRow @Param)"
                $ThisIndex++
            }
            $MonthCount++
        }
    }
    end {
        # Write the last month or row of months. Print a year heading before January when -Year is specified.
        Write-Verbose 'Print last row of months'
        if ($PSBoundParameters.ContainsKey('Year') -and $MonthHeading -match "\b$($MonthNameArray[0])\b") {
            if ($Calendar -match 'Lunisolar' -and $PrintMonth -ge 12) {
                Write-ZodiacAnimal -Calendar $Calendar -Year ( $ThisYear - 1 ) -Pretty $Pretty
            }
            $YearPad = (((18 * $MonthPerRow) + 3 - 2 ) / 2) + 2 
            $YearHeading = "$ThisYear".PadLeft($YearPad, ' ')
            Write-Output "$($Pretty.MonStyle)$YearHeading$($Pretty.MonReset)"
        }
        Write-Output "$($Pretty.MonStyle)$MonthHeading$($Pretty.MonReset)"
        Write-Output $MonthRow
        if ($PSBoundParameters.ContainsKey('Week') -and -not $IgnoreWeekRow) {
            Write-Output "$($Pretty.MonStyle)$WeekRow$($Pretty.MonReset)"
        }
        # If -Year is specified with a lunar calendar, also display the appropriate Zodiac Animal for the
        # last full year. (Ignore partial years). This should only get used when -Year is specified without
        # extra months.
        if ($PSBoundParameters.ContainsKey('Year') -and $Calendar -match 'Lunisolar' -and $ThisMonth -ge 12) {
            Write-ZodiacAnimal -Calendar $Calendar -Year $ThisYear -Pretty $Pretty
        }
    }
}