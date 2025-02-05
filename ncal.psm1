#Requires -Version 7.2 

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

function Get-CalRow {
    <#
    .NOTES
    Helper function for Get-Calendar - Prints one row of calendar output, given an Index corresponding to the 
    first day of the month.
#>
    param (
        [Parameter(Position = 0)]
        [System.Globalization.Calendar]$Calendar,

        [Parameter(Position = 1)]
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
            $PadRow = 30
            $PadDay = 3
        }
        else {
            $PadRow = 23
            $PadDay = 2
        }
    }

    process {
        # Repeat 7 times for each week day in the row 
        0..6 | ForEach-Object {
            if ($WeekDay -lt 1) {
                $Row += "{0,$PadDay} " -f $null
            }
            elseif ($WeekDay -gt $DayPerMonth) {
                #do nothing
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
            $WeekDay++
        }
        $OutString = "$($Row.TrimEnd())".PadRight($PadRow, ' ')
    
        <#
            The secret to not screwing up formatted strings with non-printable characters is to mess with the 
            string after the string is padded to the right length.
        #>
        if ( ($Highlight.Today -gt 0) -and $JulianSpecified) {
            $UseDate = $Calendar.ToDateTime($Year, $Month, $Highlight.Today, 0, 0, 0, 0, $Calendar.Eras[0] )
            $JulianDay = $Culture.Calendar.GetDayOfYear($UseDate)
        
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

function Get-Today {
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

function Get-MonthHeading {
    <# 
        .NOTES
        Helper function for Get-NCalendar and Get-Calendar. Returns a string.
    #>
    param (
        [Parameter(Position = 0)]
        [System.Globalization.CultureInfo]$Culture,

        [Parameter(Position = 1)]
        [String]$MonthName,

        [Parameter(Position = 2)]
        [Bool]$JulianSpecified
    )

    begin {
        $CallStack = Get-PSCallStack
        if ($CallStack.Count -gt 1) {
            $CallingFunction = $CallStack[1].Command
        }
    }
    process {
        if ($CallingFunction -eq 'Get-Calendar') {
            if ($true -eq $JulianSpecified) {
                $HeadingLength = 30
            }
            else {
                $HeadingLength = 23
            }
            # Special cases - resorted to hard coding for double width character sets like Kanji.
            # Japanese, traditional Chinese and Korean have 1 double width character in month name, simplified Chinese 
            # and Yi have two. This is a rough hack, but it works.
            if ($Culture.Name -match '^(ja|zh-hant|ko$|ko\-)') { $HeadingLength -= 1 }
            if ($Culture.Name -match '^(zh$|zh-hans|ii)') { $HeadingLength -= 2 }
            $Pad = $MonthName.Length + (($HeadingLength - 2 - $MonthName.Length) / 2)
            $MonthHeading = ($MonthName.PadLeft($Pad, ' ')).PadRight($HeadingLength, ' ')

        }
        # Get-NCalendar is the (default) calling function
        else {
            if ($true -eq $JulianSpecified) {
                $Pad = 24
            }
            else {
                $Pad = 19
            }
            if ($Culture.Name -match '^(ja|zh-hant|ko$|ko\-)') { $Pad -= 1 }
            if ($Culture.Name -match '^(zh$|zh-hans|ii)') { $Pad -= 2 }
            $MonthHeading = "$MonthName".PadRight($Pad, ' ')
        }
        Write-Output $MonthHeading
    }
}

function Get-FirstDayOfMonth {
    <# 
        .NOTES
        Helper function for Get-NCalendar and Get-Calendar that returns the date and day name of the first day of each 
        required month, using the specified calendar. This function performs the paramters validation for both 
        ncal and cal.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Globalization.Calendar]$Calendar,
        
        # Could be an integer between 1 and 13 or the same with an 'f' or 'p' suffix
        [Parameter(Position = 1)]
        [String]$Month,
        
        [Parameter(Position = 2)]
        [ValidateRange(1, 9999)]
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
        $Now = Get-Today -Calendar $Calendar
        Write-Verbose "today year = $($Now.Year), today month = $($Now.Month), today day = $($Now.Day)"

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
                Write-Error "'$Month' is not a valid month number"
                return
            }
        }
        else {
            # No month
            if ($PSBoundParameters.ContainsKey('Year')) {
                # Year specified with no month; showing whole year.
                [Int]$MonthNumber = 1
                [Int]$BeforeOffset = 0
                [Int]$AfterOffset = ($Calendar.GetMonthsInYear($Year) - 1)
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

        <#
            Parameter validation complete. We have the required months to show, and a target month (typically this
            month or possibly first month of required year). Get the date object of the first day of the specified
            month and then use this to determine the date object of the first day of the first require month.
        #>
        $MonthCount = 1 + $BeforeOffset + $AfterOffset
        try {
            $TargetDate = $Calendar.ToDateTime($Year, $MonthNumber, 1, 0, 0, 0, 0, $Calendar.Eras[0])
            $FirstDay = $Calendar.AddMonths($TargetDate, - $BeforeOffset)
        }
        catch {
            Write-Error "Date conversion error - $($PSItem.Exception.Message)"
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
                'FirstDayIndex' = $Calendar.GetDayOfWeek($FirstDay).value__ # Monday=1, Sunday=7
                'DayPerMonth'   = $DayPerMonth
                'MonthPerYear'  = $MonthPerYear
                'YearSpecified' = $YearSpecified # Used to determine year and month headings
            }
            $FirstDay = $Calendar.AddMonths($FirstDay, 1)
        }
    } #end process
}

function Get-StartWeekIndex {
    <#
        .NOTES
        The first day index is always 1 through 7, Monday to Sunday. This function returns an index, based on the 
        real/desired first day of the week and the actual start day. This will be a number between -5 and 1. When 
        we reach an index=1, we start printing, otherwise we print a space.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1)]
        [ValidateSet('Friday', 'Saturday', 'Sunday', 'Monday')]
        [string]$StartWeekDay,

        [Int]$FirstDayIndex
    )

    process {
        # Monday = -2 thru Sunday = -8, which means Friday-Sunday start on next column so force 1, 0, -1 resp.
        if ('Friday' -eq $StartWeekDay) {
            $ThisIndex = -1 - $FirstDayIndex
            if ($ThisIndex -eq -6) {
                $ThisIndex = 1
            }
            elseif ($ThisIndex -eq -7) {
                $ThisIndex = 0
            }
            elseif ($ThisIndex -eq -8) {
                $ThisIndex = -1
            }
        }
        # Monday = -1 thru Sunday = -7 which mean both Saturday and Sunday start on next column, so force 1 and 0 resp.
        elseif ('Saturday' -eq $StartWeekDay) {
            $ThisIndex = 0 - $FirstDayIndex
            if ($ThisIndex -eq -6) {
                $ThisIndex = 1
            }
            elseif ($ThisIndex -eq -7) {
                $ThisIndex = 0
            }
        }
        elseif ('Sunday' -eq $StartWeekDay) {
            # Monday = 0 thru Sunday = -6, which would mean start on next column, so force Sunday to be 1
            $ThisIndex = 1 - $FirstDayIndex
            if ($ThisIndex -eq -6) {
                $ThisIndex = 1
            }
        }
        else {
            # Week starts Monday. Here we need Monday = 1 thru Sunday = -5
            $ThisIndex = 2 - $FirstDayIndex
            if ($ThisIndex -eq 2) {
                $ThisIndex = -5
            }
        }
        Write-Output $ThisIndex
    }
}

function Get-WeekDayName {
    <#
        .NOTES
        Determine the localized week day names. There are globalisation issues with attempting to truncate day 
        names in some cultures, so only truncate cultures with standard character sets.

        For ncal only, MonthOffset is an attempt to fix column formats with many cultures that have mixed length 
        short and long day names. It seems to work ok providing an appropriate font is installed supporting unicode 
        characters.

        According .Net, just one language (Dhivehi - cultures dv and dv-MV), spoken in Maldives, has a week day 
        starting on Friday. Most Islamic countries (some Arabic, Persian, Pashto and one or two others) use 
        Saturday. All Western and Eastern European countries, Russia, Indian, most of Africa, Asian-Pacific 
        countries, except China and Japan follow ISO 1806 standard with Monday as the first day of the week. All 
        North and South American countries, some African, China and Japan use Sunday.

        With ncal, we want full day names or abbreviated day names (modified for some cultures).
        With cal, we want abbreviated names (shortened for some cultures) or the shortest day names.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Globalization.CultureInfo]$Culture,

        [Parameter(Mandatory, Position = 1)]
        [ValidateSet('Friday', 'Saturday', 'Sunday', 'Monday')]
        [string]$FirstDayOfWeek,

        [Parameter(Position = 2)]
        [Switch]$LongDayName,

        [Parameter(Position = 3)]
        [Switch]$JulianSpecified
    )

    begin {
        [Int]$MonthOffset = 0
        $CallStack = Get-PSCallStack
        if ($CallStack.Count -gt 1) {
            $CallingFunction = $CallStack[1].Command
        }
    }
    process {
        if ($CallingFunction -eq 'Get-Calendar') {
            # Truncate some Abbreviated day names to two characters (e.g. Mo, Tu), rather than Shortest day names (e.g. M, T)
            # for some Western languages.
            if ($Culture.Name -match '^(ja|zh|ko$|ko\-|ii)') {
                # Some cultures use double width character sets. So attempt to capture these and do not pad day names
                $WeekDay = $Culture.DateTimeFormat.ShortestDayNames
                if ($true -eq $JulianSpecified) {
                    # For day of the year, each day is 2 characters wide with double-width character sets.
                    $WeekDay = $WeekDay | ForEach-Object { "$_".PadLeft(2, ' ') }
                }
            }
            else {
                if ($Culture.Name -match '^(da|de|es|eo|en|fr|it|pt)') {
                    $WeekDay = $Culture.DateTimeFormat.AbbreviatedDayNames | ForEach-Object { "$_".Substring(0, 2) }
                }
                else {
                    # Quite a lot of cultures use a single character, so ensure the names are 2 characters.
                    $WeekDay = $Culture.DateTimeFormat.ShortestDayNames | ForEach-Object { "$_".PadLeft(2, ' ') }
                }
                if ($true -eq $JulianSpecified) {
                    # For day of the year, each day is 3 characters wide.
                    $WeekDay = $WeekDay | ForEach-Object { "$_".PadLeft(3, ' ') }
                }
            }
            Write-Verbose "Short week day - $WeekDay"
        }
        else {
            # Get-NCalendar is the (default) calling function
            if ($true -eq $LongDayName) {
                $WeekDayLong = $Culture.DateTimeFormat.DayNames
                Write-Verbose "Long week day - $WeekDayLong"
                if ($Culture.Name -match '^(ja|zh|ko$|ko\-|ii)') {
                    # Full day name for cultures that use double width character sets, double the size of the month offset but not the weekday  
                    $MonthOffset = 2 + ((($WeekDayLong | ForEach-Object { "$_".Length } | Measure-Object -Maximum).Maximum) * 2)
                    $WeekDayLength = ($WeekDayLong | ForEach-Object { "$_".Length } | Measure-Object -Maximum).Maximum
                    $WeekDay = $WeekDayLong | ForEach-Object { "$_".PadRight($WeekDayLength + 1, ' ') }
                }
                else {
                    # Full day name for cultures using latin and Persian character sets.
                    $MonthOffset = 2 + (($WeekDayLong | ForEach-Object { "$_".Length } | Measure-Object -Maximum).Maximum)
                    $WeekDay = $WeekDayLong | ForEach-Object { "$_".PadRight($MonthOffset - 1, ' ') }
                }
            }
            else {
                $WeekDayShort = $Culture.DateTimeFormat.AbbreviatedDayNames
                Write-Verbose "Abbreviated week day - $WeekDayShort"
                if ($Culture.Name -match '^(ja|zh|ko$|ko\-|ii)') {
                    # Short day names for cultures that use double width character sets
                    $MonthOffset = 2 + ((($WeekDayShort | ForEach-Object { "$_".Length } | Measure-Object -Maximum).Maximum) * 2)
                    $WeekDayLength = ($WeekDayShort | ForEach-Object { "$_".Length } | Measure-Object -Maximum).Maximum
                    $WeekDay = $WeekDayShort | ForEach-Object { "$_".PadRight($WeekDayLength + 1, ' ') }
                }
                elseif ($ThisCulture.Name -match '^(en|fr|de|it|es|pt|eo)') {
                    # Simulate the Linux ncal command with two character day names on some Western cultures.
                    $MonthOffset = 4
                    $WeekDay = $WeekDayShort | ForEach-Object { "$_".Substring(0, 2).PadRight(3, ' ') }
                }
                else {
                    # Short day name for all other cultures. 
                    $MonthOffset = 2 + (($WeekDayShort | ForEach-Object { "$_".Length } | Measure-Object -Maximum).Maximum)
                    $WeekDay = $WeekDayShort | ForEach-Object { "$_".PadRight($MonthOffset - 1, ' ') }
                }
            }
        }

        Write-Verbose "Specified/assumed first day of week is $FirstDayOfWeek"
        Write-Verbose "Cultural first day of the week is $($Culture.DateTimeFormat.FirstDayOfWeek)"

        # DayNames and AbbreviatedDayNames properties in .Net are always Sunday based, regardless of culture.
        if ('Friday' -eq $FirstDayOfWeek) {
            $WeekDay = $WeekDay[5, 6, 0, 1, 2, 3, 4]
        }
        if ('Saturday' -eq $FirstDayOfWeek) {
            $WeekDay = $WeekDay[6, 0, 1, 2, 3, 4, 5]
        }
        elseif ('Monday' -eq $FirstDayOfWeek) {
            $WeekDay = $WeekDay[1, 2, 3, 4, 5, 6, 0]
        }
        [PSCustomObject]@{
            Name   = $WeekDay
            Offset = $MonthOffset
        }
    }
}

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

        # month starts last day or week and has at least 30 days is 6 columns wide
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
            if ($_ -gt 52) {
                $WeekRow += "{0,$PadDay} " -f ($_ - 52)
            }
            else {
                $WeekRow += "{0,$PadDay} " -f $_
            }
        }
    
        $OutString = "$WeekRow".PadRight($PadRow, ' ')
        Write-Output $OutString
    } # end process
}

function Get-Highlight {
    <# 
    .NOTES
        Helper function for Get-NCalendar and Get-Calendar. Returns a list of formatting strings and the day for
        today. This is used to highlighting year/month headings, week row and todays day.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Globalization.Calendar]$Calendar,

        [Parameter(Mandatory, Position = 1)]
        [ValidateRange(1, 13)]
        [Int]$Month,
        
        [Parameter(Mandatory, Position = 2)]
        [ValidateRange(1, 9999)]
        [Int]$Year,

        [Parameter(Position = 3)]
        [ValidateSet('None', 'Red', 'Green', 'Blue', 'Yellow', 'Cyan', 'Magenta', 'White', 'Orange', $null)]
        [String]$Highlight
    )

    process {
        $Now = Get-Today -Calendar $Calendar
        if ( ($Month -eq $Now.Month) -and ($Year -eq $Now.Year) ) {
            $Today = $Now.Day
        }
        else {
            $Today = 0
        }
        if (-not $Highlight) {
            # This is the default; reverse highlight today but no highlighted month name
            Write-Output @{
                Today    = $Today
                MonStyle = $null
                MonReset = $null
                DayStyle = $PSStyle.Reverse
                DayReset = $PSStyle.ReverseOff
            }
        }
        elseif ('None' -eq $Highlight) {
            # Turn off highlighting today
            Write-Output @{
                Today = 0
            }
        }
        elseif ('Orange' -eq $Highlight) {
            # To demonstrate a non-PSStyle supplied colour
            Write-Output @{
                Today    = $Today
                MonStyle = "$($PSStyle.Foreground.FromRgb(255,131,0))$($PSStyle.Bold)"
                MonReset = $PSStyle.Reset
                DayStyle = "$($PSStyle.Background.FromRgb(255,131,0))$($PSStyle.Foreground.FromRgb(0,0,0))"
                DayReset = $PSStyle.Reset
            }
        }
        else {
            # Force the bright version of the specified colour
            $Colour = "Bright$Highlight"
            Write-Output @{
                Today    = $Today
                MonStyle = "$($PSStyle.Foreground.$Colour)$($PSStyle.Bold)"
                MonReset = $PSStyle.Reset
                DayStyle = "$($PSStyle.Background.$Colour)$($PSStyle.Foreground.FromRgb(0,0,0))"
                DayReset = $PSStyle.Reset
            }
        }
    }
}

function Get-NCalendar {
    <#
    .SYNOPSIS
        Get-NCalendar
    .DESCRIPTION
        This command displays calendar information similar to the Linux ncal command. It implements the same 
        functionality, including the ability to display multiple months, years, week number per year, day of the
        year and month forward and previous by one year.

        But in addition, the command can do a whole lot more:
        1. Display a calendar in any supported culture. Month and day names are displayed in the appropriate
        language for the specified culture and the appropriate calendar is used (e.g. Gregorian, Persian).
        2. Not only display the primary calendar (used by each culture), but also display optional calendars.
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
    .PARAMETER Month
        Specifies the required month. This must be specified as a number 0..12. An 'f' (forward by one year) or a 'p' 
        (previous year) suffix can also be appended to the month number.
    .PARAMETER Year
        Specifies the required year. If no month is specified, the whole year is shown.
    .PARAMETER Culture
        Specifies the required culture. The system default culture is used by default.
    .PARAMETER Calendar
        Instead of culture, specify the required calendar. This provides support for non-primary calendars, like 
        the Julian, Hijri and Chinese Lunar calendars.
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
    .EXAMPLE
        PS C:> ncal -calendar Julian -m 1 -a 11

        Shows this month and the following 11 months on the non-optional Julian calendar. 
        
        Note: This actually works, unlike the Linux cal command (as at Feb 2025), which sometimes shows the wrong 
        month (shows this Julian month but in terms of month number on the Gregorian calendar), depending on the 
        day of the month.
    .EXAMPLE
        PS C:> ncal -cal Hijri -m 1 -a 11

        Shows this month and the following 11 months on the optional Hijri calendar.

        Note: This is not supported on Linux cal command.
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
        # Could be integer between 1 and 12 or the same with an 'f' or 'p' suffix.
        [Parameter(Position = 0)]
        [Alias('m')]
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

        [Switch]$LongDayName,

        [switch]$Name
    )

    begin {
        $Abort = $false
        if ($PSBoundParameters.ContainsKey('Culture')) {
            try {
                $ThisCulture = New-Object System.Globalization.CultureInfo($Culture) -ErrorAction Stop
            }
            catch {
                Write-Warning "ncal: Invalid culture specified:'$Culture'. Using the system default culture ($((Get-Culture).Name)). Use 'Get-Culture -ListAvailable'."
                $ThisCulture = [System.Globalization.CultureInfo]::CurrentCulture
            }
            $ThisCalendar = $ThisCulture.Calendar
        }
        elseif ($PSBoundParameters.ContainsKey('Calendar')) {
            $CultureLookup = @{
                'Gregorian'         = 'en-AU'
                'Persian'           = 'fa-IR'
                'Hijri'             = 'ar-SA'
                'Hebrew'            = 'he-IL'
                'Japanese'          = 'ja-JP'
                'Korean'            = 'ko-KR'
                'Taiwan'            = 'zh-Hant-TW'
                'UmAlQura'          = 'ar-SA'
                'ThaiBuddhist'      = 'th-th'
                'Julian'            = 'en-AU'
                'ChineseLunisolar'  = 'zh'
                'JapaneseLunisolar' = 'ja'
                'KoreanLunisolar'   = 'ko'
                'TaiwanLunisolar'   = 'zh-Hant-TW'
            }
            # This method only works for the Optional calendars of a culture.
            $ThisCulture = New-Object System.Globalization.CultureInfo($($CultureLookup[$Calendar]))
            $ThisCalendar = New-Object "System.Globalization.$($Calendar)Calendar"
        }
        else {
            $ThisCulture = [System.Globalization.CultureInfo]::CurrentCulture
            $ThisCalendar = $ThisCulture.Calendar
        }

        # Display the Culture/Calendar name as a heading
        if ($PSBoundParameters.ContainsKey('Name') -and $PSBoundParameters.ContainsKey('Calendar')) {
            $CalendarString = $($ThisCalendar.ToString().Replace('System.Globalization.', '').Replace('Calendar', ' Calendar'))   
            Write-Output "$($PSStyle.Reverse)--|$CalendarString|--$($PSStyle.ReverseOff)`n"
        }
        elseif ($PSBoundParameters.ContainsKey('Name')) {
            $CalendarString = $($ThisCulture.Calendar.ToString().Replace('System.Globalization.', '').Replace('Calendar', ' Calendar'))
            Write-Output "$($PSStyle.Reverse)--|$($ThisCulture.Name)|-|$($ThisCulture.DisplayName)|-|$CalendarString|--$($PSStyle.ReverseOff)`n"
        }

        # Full month names in current culture
        $MonthNameArray = $ThisCulture.DateTimeFormat.MonthGenitiveNames

        # Calling DayOfYear 'Julian' is incorrect. JulianDay is something else altogether. However keep 'Julian' as
        # its more eye-catching.
        if ($PSBoundParameters.ContainsKey('DayOfYear')) {
            [Bool]$JulianSpecified = $true
        }
        else {
            [Bool]$JulianSpecified = $false
        }

        # List of short day names in the required order.
        if ($PSBoundParameters.ContainsKey('FirstDayOfWeek')) {
            $Param = @{
                'Culture'         = $ThisCulture
                'FirstDayOfWeek'  = $FirstDayOfWeek
                'JulianSpecified' = $JulianSpecified
                'LongDayName'     = $LongDayName
            }
            $WeekDay = Get-WeekDayName @Param
        }
        else {
            $DefaultFirstDay = $ThisCulture.DateTimeFormat.FirstDayOfWeek
            $Param = @{
                'Culture'         = $ThisCulture
                'FirstDayOfWeek'  = $DefaultFirstDay
                'JulianSpecified' = $JulianSpecified
                'LongDayName'     = $LongDayName
            }
            $WeekDay = Get-WeekDayName @Param

            # Get the date of the first day of each required month, based on the culture (common to ncal & cal)
            $DateParam = New-Object -TypeName System.Collections.Hashtable
            $DateParam.Add('Calendar', $ThisCalendar)
            if ($PSBoundParameters.ContainsKey('Month')) {
                $DateParam.Add('Month', $Month)
            }
            if ($PSBoundParameters.ContainsKey('Year')) {
                $DateParam.Add('Year', $Year)
            }
            if ($PSBoundParameters.ContainsKey('Before')) {
                $DateParam.Add('Before', $Before)
            }
            if ($PSBoundParameters.ContainsKey('After')) {
                $DateParam.Add('After', $After)
            }
            if ($PSBoundParameters.ContainsKey('Three')) {
                $DateParam.Add('Three', $Three)
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
            $Pretty = Get-Highlight $ThisCalendar $ThisMonth $ThisYear $Highlight
            if ($PSBoundParameters.ContainsKey('Calendar')) {
                Write-Verbose "monthname = $MonthName, thismonth = $ThisMonth, thisyear = $ThisYear, dayspermonth = $DayPerMonth, monthcount = $MonthCount, calendar = $($ThisCalendar.ToString().Replace('System.Globalization.', '')), era = $($ThisCalendar.Eras[0])"
            }
            else {
                Write-Verbose "monthname = $MonthName, thismonth = $ThisMonth, thisyear = $ThisYear, dayspermonth = $DayPerMonth, monthcount = $MonthCount, culture = $($ThisCulture.Name)"
            }

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
                        'Calendar'        = $ThisCalendar
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
                        'Calendar'        = $ThisCalendar
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
                    'Calendar'        = $ThisCalendar
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

function Get-Calendar {
    <#
    .SYNOPSIS
        Get-Calendar
    .DESCRIPTION
        This command displays calendar information similar to the Linux cal command. It implements the same 
        functionality, including the ability to display multiple months, years, day of the year and month forward 
        and previous by one year.

        But in addition, the command can do a whole lot more:
        1. Display a calendar in any supported culture. Month and day names are displayed in the appropriate
        language for the specified culture and the appropriate calendar is used (e.g. Gregorian, Persian).
        2. Not only display the primary calendar (used by each culture), but also display optional calendars.
        These are Hijri, Hebrew, Japanese (Solar), Korean (Solar) and Taiwanese (Solar) calendars. In addition,
        the non-optional calendars (i.e. calendars not used by any culture, but still observed for religious, 
        scientific or traditional purposes). These are the Julian and Chinese, Japanese, Korean and Taiwanese Lunar
        calendars. (Note: Only the current era is supported).
        3. Specify the first day of the week (Friday through Monday). The specified or current culture setting is 
        used by default. Friday through Monday are supported because all cultures use one of these days.
        4. Display one to six months in a row, when multiple months are displayed (the default is 3).
        5. Highlight the year and month headings, todays date and week numbers using a specified colour.
        
        It is highly recommended that Windows Terminal is used with an appropriate font to ensure that ISO unicode
        character sets are both available and are displayed correctly. With other consoles, like Visual Studio Code,
        the ISE and the default PowerShell console, some fonts might not display correctly and with extended unicode
        character sets, calendars may appear misaligned.  
    .PARAMETER Month
        Specifies the required month. This must be specified as a number 0..12. An 'f' (forward by one year) or a 'p' 
        (previous year) suffix can also be appended to the month number.
    .PARAMETER Year
        Specifies the required year. If no month is specified, the whole year is shown.
    .PARAMETER Culture
        Specifies the required culture. The system default culture is used by default.
    .PARAMETER Calendar
        Instead of culture, specify the required calendar. This provides support for non-primary calendars, like 
        the Julian, Hijri and Chinese Lunar calendars.
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
    .EXAMPLE
        PS C:\> cal
        
        Displays this month
    .EXAMPLE
        PS C:\> cal -m 1 -a 11
        
        Displays this year in any culture. for example, -y 2025 with cultures that do not use the Gregorian calendar
        by default will not work or produce unintended results. Some cultures use the Persian (Iranian), ThaiBuddist 
        and UmAlQura (Umm al-Qura, Saudi Arabian) calendars by default.
    .EXAMPLE
        PS C:\> cal -m 1f
        
        Displays January forward 1 year, Or January next year. -m 1p show January from previous year
    .EXAMPLE
        PS C:\> cal -m 4 -y 2021 -b 2 -a 1
        
        Displays April 2021 with the two months before and the month after it.
    .EXAMPLE
        PS C:\> cal -y 2021 -a 24
        
        Shows 2021 through 2023
    .EXAMPLE
        PS C:\> cal -j -three 
        
        Show Julian days for last month, this month and next month
    .EXAMPLE
        PS C:\> cal 2 2022 -three 
        
        Show February 2022 together with the month prior and month after.
    .EXAMPLE
        PS C:> cal -Y 2021 -Highlight Red

        Shows the specified year with a highlighted colour. Supports red, blue, green, yellow
        cyan, magenta and white. Disable all highlighting with 'none'.
    .EXAMPLE
        PS C:> cal -calendar Julian -m 1 -a 11

        Shows this month and the following 11 months on the non-optional Julian calendar.

        Note: This actually works, unlike the Linux cal command (as at Feb 2025), which sometimes shows the wrong 
        month (shows this Julian month but in terms of month number on the Gregorian calendar), depending on the 
        day of the month.
    .EXAMPLE
        PS C:> cal -cal Hijri -m 1 -a 11

        Shows this month and the following 11 months on the optional Hijri calendar.

        Note: This is not supported on Linux cal command.
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
    [Alias('cal')]
    [CmdletBinding(DefaultParameterSetName = 'UseCulture')]
    param(
        # Could be integer between 1 and 12 or the same with an 'f' or 'p' suffix.
        [Parameter(Position = 0)]
        [Alias('m')]
        [String]$Month,
        
        [Parameter(Position = 1)]
        [ValidateRange(1, 9999)]
        [Int]$Year,

        [parameter(Position = 2, ParameterSetName = 'UseCulture')]
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

        [parameter(Position = 3)]
        [ValidateSet('Friday', 'Saturday', 'Sunday', 'Monday')]
        [String]$FirstDayOfWeek,

        [parameter(Position = 4)]
        [ValidateRange(1, 6)]
        [Int]$MonthPerRow = 3,

        [parameter(Position = 5)]
        [ValidateSet('None', 'Red', 'Green', 'Blue', 'Yellow', 'Cyan', 'Magenta', 'White', 'Orange')]
        [String]$Highlight,

        [Int]$Before,

        [Int]$After,

        [Switch]$Three,

        [Switch]$DayOfYear,

        [Switch]$Name
    )

    begin {
        $Abort = $false
        if ($PSBoundParameters.ContainsKey('Culture')) {
            try {
                $ThisCulture = New-Object System.Globalization.CultureInfo($Culture) -ErrorAction Stop
            }
            catch {
                Write-Warning "ncal: Invalid culture specified:'$Culture'. Using the system default culture ($((Get-Culture).Name)). Use 'Get-Culture -ListAvailable'."
                $ThisCulture = [System.Globalization.CultureInfo]::CurrentCulture
            }
            $ThisCalendar = $ThisCulture.Calendar
        }
        elseif ($PSBoundParameters.ContainsKey('Calendar')) {
            $CultureLookup = @{
                'Gregorian'         = 'en-AU'
                'Persian'           = 'fa-IR'
                'Hijri'             = 'ar-SA'
                'Hebrew'            = 'he-IL'
                'Japanese'          = 'ja-JP'
                'Korean'            = 'ko-KR'
                'Taiwan'            = 'zh-Hant-TW'
                'UmAlQura'          = 'ar-SA'
                'ThaiBuddhist'      = 'th-th'
                'Julian'            = 'en-AU'
                'ChineseLunisolar'  = 'zh'
                'JapaneseLunisolar' = 'ja'
                'KoreanLunisolar'   = 'ko'
                'TaiwanLunisolar'   = 'zh-Hant-TW'
            }
            # This method only works for the Optional calendars of a culture.
            $ThisCulture = New-Object System.Globalization.CultureInfo($($CultureLookup[$Calendar]))
            $ThisCalendar = New-Object "System.Globalization.$($Calendar)Calendar"
        }
        else {
            $ThisCulture = [System.Globalization.CultureInfo]::CurrentCulture
            $ThisCalendar = $ThisCulture.Calendar
        }

        # Display the Culture/Calendar name as a heading
        if ($PSBoundParameters.ContainsKey('Name') -and $PSBoundParameters.ContainsKey('Calendar')) {
            $CalendarString = $($ThisCalendar.ToString().Replace('System.Globalization.', '').Replace('Calendar', ' Calendar'))   
            Write-Output "$($PSStyle.Reverse)--|$CalendarString|--$($PSStyle.ReverseOff)`n"
        }
        elseif ($PSBoundParameters.ContainsKey('Name')) {
            $CalendarString = $($ThisCulture.Calendar.ToString().Replace('System.Globalization.', '').Replace('Calendar', ' Calendar'))
            Write-Output "$($PSStyle.Reverse)--|$($ThisCulture.Name)|-|$($ThisCulture.DisplayName)|-|$CalendarString|--$($PSStyle.ReverseOff)`n"
        }

        # Full month names in current culture
        $MonthNameArray = $ThisCulture.DateTimeFormat.MonthGenitiveNames

        # Calling DayOfYear 'Julian' is incorrect. JulianDay is something else altogether. However keep 'Julian' as
        # its more eye-catching.
        if ($PSBoundParameters.ContainsKey('DayOfYear')) {
            [Bool]$JulianSpecified = $true
        }
        else {
            [Bool]$JulianSpecified = $false
        }

        # List of short day names in the required order.
        if ($PSBoundParameters.ContainsKey('FirstDayOfWeek')) {
            $Param = @{
                'Culture'         = $ThisCulture
                'FirstDayOfWeek'  = $FirstDayOfWeek
                'JulianSpecified' = $JulianSpecified
            }
            $WeekDay = Get-WeekDayName @Param
        }
        else {
            $DefaultFirstDay = $ThisCulture.DateTimeFormat.FirstDayOfWeek
            $Param = @{
                'Culture'         = $ThisCulture
                'FirstDayOfWeek'  = $DefaultFirstDay
                'JulianSpecified' = $JulianSpecified
            }
            $WeekDay = Get-WeekDayName @Param
        }

        # Get the date of the first day of each required month, based on the culture (common to ncal & cal)
        $DateParam = New-Object -TypeName System.Collections.Hashtable
        $DateParam.Add('Calendar', $ThisCalendar)
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

        # initialize a strongly typed, fixed length array with no values.
        $MonthRow = New-Object -TypeName System.String[] -ArgumentList 7
        $MonthCount = 0
        $MonthHeading = ''
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
            $Pretty = Get-Highlight $ThisCalendar $ThisMonth $ThisYear $Highlight
            if ($PSBoundParameters.ContainsKey('Calendar')) {
                Write-Verbose "monthname = $MonthName, thismonth = $ThisMonth, thisyear = $ThisYear, dayspermonth = $DayPerMonth, monthcount = $MonthCount, calendar = $($ThisCalendar.ToString().Replace('System.Globalization.', '')), era = $($ThisCalendar.Eras[0])"
            }
            else {
                Write-Verbose "monthname = $MonthName, thismonth = $ThisMonth, thisyear = $ThisYear, dayspermonth = $DayPerMonth, monthcount = $MonthCount, culture = $($ThisCulture.Name)"
            }

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
                'StartWeekDay'  = $StartWeekDay
                'FirstDayIndex' = $FirstDayIndex
            }
            $ThisIndex = Get-StartWeekIndex @Param

            # User can choose number of months to print per row, default is 3. In this case, just append the month.
            if ($MonthCount -lt $MonthPerRow) {
                $Param = @{
                    'Culture'         = $ThisCulture
                    'MonthName'       = $MonthName
                    'JulianSpecified' = $JulianSpecified
                }
                $MonthHeading += "$(Get-MonthHeading @Param)"
            }
            else {
                # Print a year heading before January when year is specified when the year is not already in month name
                if ($MonthHeading -match "\b$($MonthNameArray[0])\b" -and $MonthName -notmatch $ThisYear) {
                    $YearPad = (((22 * $MonthPerRow) - 2 ) / 2) + 2
                    $YearHeading = "$ThisYear".PadLeft($YearPad, ' ')
                    Write-Output "$($Pretty.MonStyle)$YearHeading$($Pretty.MonReset)"
                }
                Write-Output "$($Pretty.MonStyle)$MonthHeading$($Pretty.MonReset)"
                Write-Output $MonthRow
                Write-Output ''

                # Reset for next row of months
                $MonthRow = New-Object -TypeName System.String[] -ArgumentList 7
                $MonthCount = 0
                $Param = @{
                    'Culture'         = $ThisCulture
                    'MonthName'       = $MonthName
                    'JulianSpecified' = $JulianSpecified
                }
                $MonthHeading = "$(Get-MonthHeading @Param)"
            }

            $MonthRow[0] += "$($WeekDay.Name)" + '   '
            1..6 | ForEach-Object {
                $Param = @{
                    'Calendar'        = $ThisCalendar
                    'Index'           = $ThisIndex
                    'DayPerMonth'     = $DayPerMonth
                    'Month'           = $ThisMonth
                    'Year'            = $ThisYear
                    'Highlight'       = $Pretty
                    'JulianSpecified' = $JulianSpecified
                }
                $MonthRow[$_] += "$(Get-CalRow @Param)"
                $ThisIndex += 7
            }
            $MonthCount++
        }
    }

    end {
        # Write the last month or row of months
        # Print a year heading before Month 1 when year is specified
        if (-Not $Abort) {
            if ($MonthHeading -match "\b$($MonthNameArray[0])\b" -and $MonthName -notmatch $ThisYear) {
                $YearPad = (((22 * $MonthPerRow) - 2 ) / 2) + 2 
                $YearHeading = "$ThisYear".PadLeft($YearPad, ' ')
                Write-Output "$($Pretty.MonStyle)$YearHeading$($Pretty.MonReset)"
            }
            Write-Output "$($Pretty.MonStyle)$MonthHeading$($Pretty.MonReset)"
            Write-Output $MonthRow
        }
    }
}

function Get-Now {
    <#
    .SYNOPSIS
        Get today's date in any of the calendars supported by .NET
    .DESCRIPTION
        Displays today's date in any of the calendars supported ny .NET Framework. By default, today's date for
        every supported calendar is shown. The Gregorian calendar is always shown, to compare with the specified
        calendar.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        https://github.com/atkinsroy/ncal/docs
    .EXAMPLE
        Get-Now
        
        Displays today's date in every supported calendar
    .EXAMPLE
        Get-Now -Calendar Persian,Hijri,UmAlQura

        Displays today's date for each specified calendar, along with the Gregorian calendar.
    #>

    [CmdletBinding()]
    param (
        [parameter(Position = 0)]
        [ValidateSet(
            'Julian',
            'Hijri',
            'Persian',
            'UmAlQura',
            'ChineseLunisolar',
            'Hebrew',
            'Japanese',
            'JapaneseLunisolar',
            'Korean',
            'KoreanLunisolar',
            'Taiwan',
            'TaiwanLunisolar',
            'ThaiBuddhist'
        )]
        [String[]]$Calendar = @(
            'Julian',
            'Hijri',
            'Persian',
            'UmAlQura',
            'ChineseLunisolar',
            'Hebrew',
            'Japanese',
            'JapaneseLunisolar',
            'Korean',
            'KoreanLunisolar',
            'Taiwan',
            'TaiwanLunisolar',
            'ThaiBuddhist')
    )

    begin {
        $Now = Get-Date
        $Cal = New-Object -TypeName 'System.Globalization.GregorianCalendar'
        $CalMonth = $Cal.GetMonth($Now)
        $CalYear = $Cal.GetYear($Now)
        [PSCustomObject] @{
            'PSTypeName'   = 'Ncal.Date'
            'Calendar'     = 'GregorianCalendar'
            'Day'          = $Cal.GetDayOfMonth($Now)
            'Month'        = $CalMonth
            'Year'         = $CalYear
            'DaysInMonth'  = $Cal.GetDaysInMonth($CalYear, $CalMonth)
            'MonthsInYear' = $Cal.GetMonthsInYear($CalYear)
            'Era'          = $Cal.Eras[0]
        } 
    }

    process {
        foreach ($ThisCalendar in $Calendar) {
            $ThisCalendarString = "$($ThisCalendar)Calendar"
            $Cal = New-Object -TypeName "System.Globalization.$ThisCalendarString"
            $CalMonth = $Cal.GetMonth($Now)
            $CalYear = $Cal.GetYear($Now)
            [PSCustomObject] @{
                'PSTypeName'   = 'Ncal.Date'
                'Calendar'     = $ThisCalendarString
                'Day'          = $Cal.GetDayOfMonth($Now)
                'Month'        = $CalMonth
                'Year'         = $CalYear
                'DaysInMonth'  = $Cal.GetDaysInMonth($CalYear, $CalMonth)
                'MonthsInYear' = $Cal.GetMonthsInYear($CalYear)
                'Era'          = $Cal.Eras[0]
            } 
        }
    }
}