# Helper function for Get-Calendar - Prints one row of calendar output, given an Index corresponding to the first 
# day of the month.
function Get-DateRow {
    Param (
        # valid range is -5 to 1.
        [Parameter(Position = 0)]
        [Int]$Index,
        
        [Parameter(Position = 1)]
        [ValidateRange(28, 31)]
        [Int]$DayPerMonth,

        [Parameter(Position = 2)]
        [ValidateRange(1, 12)]
        [String]$Month,

        [Parameter(Position = 3)]
        [ValidateRange(1000, 9999)]
        [String]$Year,

        [Parameter(Position = 4)]
        [bool]$JulianSpecified,

        [Parameter(Position = 5)]
        [object]$Highlight
    ) 

    $WeekDay = $Index
    $Row = ''

    if ($JulianSpecified) {
        $PadRow = 23
        $PadMonth = 3
    }
    else {
        $PadRow = 18
        $PadMonth = 2
    }

    do {
        if ($Weekday -lt 1) {
            $Row += "{0,$PadMonth} " -f $null
        }
        else {
            if ($JulianSpecified) {
                $JulianDay = Get-Date ([datetime]::new($Year, $Month , $WeekDay )) -UFormat %j 
                $Row += "{0,$PadMonth} " -f $JulianDay
            }
            else {
                $Row += "{0,$PadMonth} " -f $Weekday
            }
        }
        $WeekDay += 7
    }
    until ($WeekDay -gt $DayPerMonth)
    
    
    $OutString = "$Row".PadRight($PadRow, ' ')
    

    # The secret to not screwing up formatted strings with non-printable characters is to mess with the string 
    # after the string is padded to the right length.
    if ( ($Highlight.Today -gt 0) -and $JulianSpecified) {
        $JulianDay = Get-Date ([datetime]::new($Year, $Month, ($Highlight.Today))) -UFormat %j
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
    Write-Verbose "|$OutString| Length = $($OutString.Length)"
}

# Helper function for Get-Calendar that returns the first day of each required month, using current locale. Returns an 
# array of date objects.
function Get-FirstDayOfMonth {
    Param (
        [Parameter(Position = 0)]
        [ValidateRange(1, 12)]
        [Int]$Month,
        
        [Parameter(Position = 1)]
        [ValidateRange(1000, 9999)]
        [Int]$Year,
        
        [Parameter(Position = 2)]
        [Int]$OffsetBefore,
        
        [Parameter(Position = 3)]
        [Int]$OffsetAfter
    )
    $MonthCount = 1 + $OffsetBefore + $OffsetAfter
    $TargetDate = [datetime]::new($Year, $Month, 1)
    $FirstDay = (Get-Date -Date $TargetDate).AddMonths(-$OffsetBefore)
    
    for ($i = 1; $i -le $MonthCount; $i++) {
        Write-Output $FirstDay
        $FirstDay = (Get-Date -Date $FirstDay).AddMonths(1)
    }
}

# Helper function for Get-Calendar. Returns a string.
function Get-MonthHeading {
    param (
        [Parameter(Position = 0)]
        [String]$MonthName,
        
        [Parameter(Position = 1)]
        [Int]$ThisYear,
        
        [Parameter(Position = 2)]
        [bool]$YearSpecified,

        [Parameter(Position = 3)]
        [bool]$JulianSpecified
    )
    if ($JulianSpecified) {
        $Pad = 24
    }
    else {
        $Pad = 19
    }
    if ($YearSpecified) {
        Write-Output "$MonthName".PadRight($Pad, ' ')
    }
    else {
        Write-Output "$MonthName $ThisYear".PadRight($Pad, ' ')
    }
}

# Helper function for GetCalendar. Prints the week number to display beneath each column

# NOTE: Originally tried getting week number of the first and last day of the month. This doesn't match Linux ncal,
# So getting the first days' week number and incrementing for the month is pretty close to ncal, although not identical.
function Get-WeekNumber {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateRange(1, 12)]
        [String]$Month,

        [Parameter(Position = 1)]
        [ValidateRange(1000, 9999)]
        [String]$Year,

        [Parameter(Position = 2)]
        [bool]$JulianSpecified
    )

    $PadMonth = "$Month".PadLeft(2, '0') 
    $FirstDate = ([datetime]::ParseExact("01/$PadMonth/$Year", 'dd/MM/yyyy', $null))
    [Int]$FirstWeek = Get-Date -Date $FirstDate -UFormat %V
    [String]$WeekRow = ''
    [Int]$WeekCount = 4

    if ($FirstWeek -ge 52 ) {
        $StartYear = $true
        $FirstWeek = 1
        $WeekCount = 3
    }
    
    if ($JulianSpecified) {
        $PadRow = 24
        $PadDay = 3
        if ($StartYear) { $WeekRow = ' 52 ' + $WeekRow }
    }
    else {
        $PadRow = 19
        $PadDay = 2
        if ($StartYear) { $WeekRow = '52 ' + $WeekRow }
    }
    
    $LastWeek = $FirstWeek + $WeekCount
    $FirstWeek..$LastWeek | ForEach-Object {
        if ($_ -eq 53) {
            $WeekRow += "{0,$PadDay} " -f 1
        }
        else {
            $WeekRow += "{0,$PadDay} " -f $_
        }
    }
    
    $OutString = "$WeekRow".PadRight($PadRow, ' ')
    Write-Output $OutString
    #Write-Verbose "|$OutString| $($OutString.Length)"
}

# Helper function for Get-Calendar. Returns an array with todays day if it is today as well as formatting strings
function Get-Highlight {
    param (
        [Parameter(Position = 0)]
        [ValidateRange(1, 12)]
        [Int]$Month,
        
        [Parameter(Position = 1)]
        [ValidateRange(1000, 9999)]
        [Int]$Year,

        [Parameter(Position = 2)]
        [ValidateSet('None', 'Red', 'Green', 'Blue', 'Yellow', 'Cyan', 'Magenta', 'White', $null)]
        [String]$Highlight
    )

    $Date = Get-Date
    if ( ($Month -eq $Date.Month) -and ($Year -eq $Date.Year) ) {
        $Today = $Date.Day
    }
    else {
        $Today = 0
    }

    if (-Not $Highlight) {
        # The default is reverse highlight today but no highlighted month name
        Write-Output @{
            Today    = $Today
            MonStyle = $null
            MonReset = $null
            DayStyle = $PSStyle.Reverse
            DayReset = $PSStyle.ReverseOff  
        }
    }
    else {
        if ($Highlight -eq 'None') {
            Write-Output @{
                Today = 0
            }
        }
        else {
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

<#
.SYNOPSIS
    Get-Calendar
.DESCRIPTION
    This command displays calendar information similar to the Linux ncal command. It implements most of the
    main functionality, including the ability to display multiple months, years, week numbers, julian day and 
    highlights for the current day.
    
    813 locales have been tested, with localised month names and day abbreviations being used. Locales using unicode
    character sets should work providing an appropriate font is used in the terminal. 
.PARAMETER Month
    Specifies the required month. This can be specified as a number 0..12 or as the (current culture) month name. An
    'f' (forward by one year) or a 'p' (backwards one year) can also be appended to the month number.
.PARAMETER Year
    Specifies the required year. If no month is specified, the whole year is shown. This is ignored if a month with
    an 'f' or a 'p' is also specified.
.PARAMETER After
    The specified number of months are added to the end of the display. This is in addition to any date range 
    selected by the -Year or -Three options. For example, ncal -y 2021 -B 2 -A 2 will show from November 2020 to
    February 2022. Negative numbers are allowed, in which case the specified number of months is subtracted. For
    example, ncal -Y 2021 -B -6 shows July to December. Amd ncal -A 11 simply shows the next 12 months.
.PARAMETER Before
    The specified number of months are added to the beginning of the display. See -After for examples.
.PARAMETER Three
    Display the previous, current and next month surrounding the requested month. If -Year is also specified, this 
    parameter is ignored.
.PARAMETER Highlight
    By default, today's date is highlighted. Either disable highlighting with 'None' or specify a colour.
.PARAMETER Week
    Print the number of the week below each week column
.PARAMETER JulianDay
    Display Julian days (days one-based, numbered from 1st January)
.PARAMETER FirstDayMonday
    Display Monday as the first day of the week. By default, this is Sunday.
.EXAMPLE
    PS C:\> ncal
    
    Displays this month
.EXAMPLE
    PS C:\> ncal -y 2021
    
    Displays each month of the specified year
.EXAMPLE
    PS C:\> ncal -m 1f
    
    Displays January forward 1 year, Or January next year. -m 1p show January from previous year
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

    Shows the specified year with a highlighted colour. Supports red, blue, green, yellow
    cyan, magenta and white. Disable all highlighting with 'none'.
.INPUTS
    [System.String]
    [System.Int]
.OUTPUTS
    [System.String]
.NOTES
    Author: Roy Atkins

    Missing ncal functionality: 
    -C to switch to 'cal mode', 
    -J Julian Calendar and other Julian Calendar support e.g -p and -s, 
    -o and -e to Easter for Orthodox and Western Churches resp.
    passing specific dates and highlight dates for debug purposes
#>
function Get-Calendar {
    [Alias('ncal')]
    [CmdletBinding()]
    param(
        # Normal PS validation of month is tricky because of month name locale support and the need to accept month numbers 
        [Parameter(Position = 0)]
        [String]$Month,
        
        [Parameter(Position = 1)]
        [ValidateRange(1000, 9999)]
        [Int]$Year,

        [Int]$Before,

        [Int]$After,

        [Switch]$Three,

        [ValidateSet('None', 'Red', 'Green', 'Blue', 'Yellow', 'Cyan', 'Magenta', 'White')]
        [String]$Highlight,

        [Switch]$Week,

        [Switch]$JulianDay,

        [Switch]$FirstDayMonday
    )

    # Day abbreviations in current culture - There are globalisation issues with truncated day names in some cultures, so use full PS abbreviation

    # Note: $AbbrevSize is an attempt to fix column formats with many cultures that have mixed length abbreviations. It seems to work ok providing
    # an appropriate font is installed supporting unicode characters.
    if ((Get-Culture).Name -match '^en|fr|it|es') {
        $WeekDayArray = [cultureinfo]::CurrentCulture.DateTimeFormat.AbbreviatedDayNames | ForEach-Object { "$_".Substring(0, 2) }
        $AbbrevSize = 2
    }
    else {
        $WeekDayArray = [cultureinfo]::CurrentCulture.DateTimeFormat.AbbreviatedDayNames
        $AbbrevSize = $WeekDayArray | ForEach-Object { "$_".Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
        $WeekDayArray = $WeekDayArray | ForEach-Object { "$_".PadRight($AbbrevSize, ' ') }
    }

    # Month names in current culture, e.g. January, February
    $MonthNameArray = [cultureinfo]::CurrentCulture.DateTimeFormat.MonthGenitiveNames
    $YearSpecified = $false
    $IgnoreOffset = $false

    # Parameter validation start
    if ($PSBoundParameters.ContainsKey('FirstDayMonday')) {
        # Note: CultureInfo .Net type defaults to Sunday as start of week. This is different to Linux style -UFormat, which is Monday.
        $WeekDayArray = (1..6 | ForEach-Object { $WeekDayArray[$_] }) + $WeekDayArray[0]
    }

    if ($PSBoundParameters.ContainsKey('JulianDay')) {
        $JulianSpecified = $true
    }
    else {
        $JulianSpecified = $false
    }

    if ($PSBoundParameters.ContainsKey('Month')) {
        $OffsetAfter = 0
        $OffsetAfter = 0

        if (-Not $PSBoundParameters.ContainsKey('Year')) {
            $Year = Get-Date -Format 'yyyy'
        }
    
        if ($Month -in 1..12) {
            $MonthNumber = $Month
        }
        elseif ($Month.Length -gt 2 -and $MonthNameArray -match $Month) {
            $MonthName = $MonthNameArray -match $Month
            $MonthNumber = ([cultureinfo]::CurrentCulture.DateTimeFormat.MonthGenitiveNames).IndexOf("$MonthName") + 1
        }
        elseif ($Month -match '^(0?[1-9]|1[0-2])[Ff]$') {
            #trailing 'f' means this month forward 1 year
            $MonthNumber = ($Month | Select-String -Pattern '^\d+').Matches.Value
            $Year += 1
        }
        elseif ($Month -match '^(0?[1-9]|1[0-2])[Pp]$') {
            #trailing 'p' means this month previous 1 year
            $MonthNumber = ($Month | Select-String -Pattern '^\d+').Matches.Value
            $Year -= 1
        }
        else {
            throw "ncal: $Month is neither a month number (1..12) nor a name"
        }
    }
    else {
        # No month
        if ($PSBoundParameters.ContainsKey('Year')) {
            # Year specified with no month; showing whole year
            $MonthNumber = 1
            $OffsetBefore = 0
            $OffsetAfter = 11
            $YearSpecified = $true
            $IgnoreOffset = $true
        }
        else {
            # Default is this month only
            $MonthNumber = Get-Date -Format 'MM'
            $Year = Get-Date -Format 'yyyy'
        }
    }

    # These options all add additional months around the month or year already identified
    if ($PSBoundParameters.ContainsKey('Three') -and -not $IgnoreOffset) {
        $OffsetBefore = 1
        $OffsetAfter = 1
    }
    if ($PSBoundParameters.ContainsKey('Before')) {
        $OffsetBefore += $Before
    }
    if ($PSBoundParameters.ContainsKey('After')) {
        $OffsetAfter += $After
    }
    # Parameter validation end

    # Get the date of the first day of each required month
    $MonthList = Get-FirstDayOfMonth $MonthNumber $Year $OffsetBefore $OffsetAfter

    # To hold each row for 1 to 4 months, initialised with culture specific day abbreviation
    [System.Collections.Generic.List[String]]$MonthRow = $WeekDayArray

    $MonthCount = 0
    $MonthHeading = ' ' * ($AbbrevSize + 1)
    $WeekRow = (' ' * ($AbbrevSize + 1))
    
    foreach ($RequiredMonth in $MonthList) {
        $ThisMonth = $RequiredMonth.Month
        $ThisYear = $RequiredMonth.Year
        $MonthName = $MonthNameArray[$ThisMonth - 1]
        
        # for highlighting today
        $Pretty = Get-Highlight $ThisMonth $ThisYear $Highlight

        $DayPerMonth = [DateTime]::DaysInMonth($ThisYear, $ThisMonth)
        Write-Verbose "monthname = $MonthName, thismonth = $ThisMonth, thisyear = $ThisYear, dayspermonth = $DayPerMonth"

        if ($MonthCount -lt 4) {
            $MonthHeading += Get-MonthHeading $MonthName $ThisYear $YearSpecified $JulianSpecified
            if ($PSBoundParameters.ContainsKey('Week')) {
                $WeekRow += Get-WeekNumber $ThisMonth $ThisYear $JulianSpecified
            }  
        }
        else {
            # Print a year heading before January when year is specified
            if ($MonthHeading -match $MonthNameArray[0] -and $YearSpecified) {
                $YearHeading = "$ThisYear".PadLeft(39, ' ')
                Write-Output "$($Pretty.MonStyle)$YearHeading$($Pretty.MonReset)"
            }
            Write-Output "$($Pretty.MonStyle)$MonthHeading$($Pretty.MonReset)"
            Write-Output $MonthRow
            if ($PSBoundParameters.ContainsKey('Week')) {
                Write-Output "$($Pretty.MonStyle)$WeekRow$($Pretty.MonReset)"
            }
            Write-Output ''
            
            # Reset for next row of 4 months
            [System.Collections.Generic.List[String]]$MonthRow = $WeekDayArray
            $MonthCount = 0
            $MonthHeading = (' ' * ($AbbrevSize + 1)) + "$(Get-MonthHeading $MonthName $ThisYear $YearSpecified $JulianSpecified)"
            if ($PSBoundParameters.ContainsKey('Week')) {
                $WeekRow = (' ' * ($AbbrevSize + 1)) + "$(Get-WeekNumber $ThisMonth $ThisYear $JulianSpecified)"
            }
        }

        if ($PSBoundParameters.ContainsKey('FirstDayMonday')) {
            # Week starts Monday by default with Uformat. Here we need Monday = 1 thru Sunday = -5
            $ThisIndex = 2 - (Get-Date $RequiredMonth -UFormat %u)
        }
        else {
            # Week starts Sunday - Monday = 0 thru Sunday = -6, which would mean start of next column, so force Sunday to be 1
            $ThisIndex = 1 - (Get-Date $RequiredMonth -UFormat %u)
            if ($ThisIndex -eq -6) { $ThisIndex = 1 }
        }
        0..6 | ForEach-Object {
            $MonthRow[$_] += " $(Get-DateRow  $ThisIndex $DayPerMonth $ThisMonth $Year $JulianSpecified $Pretty)"
            $ThisIndex++
        }
        $MonthCount++
    }
    # Write the last month or months
    Write-Output "$($Pretty.MonStyle)$MonthHeading$($Pretty.MonReset)"
    Write-Output $MonthRow
    if ($PSBoundParameters.ContainsKey('Week')) {
        Write-Output "$($Pretty.MonStyle)$WeekRow$($Pretty.MonReset)"
    }
}