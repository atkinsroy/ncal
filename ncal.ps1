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
        [object]$IsThisMonth,

        [Parameter(Position = 3)]
        [object]$Pretty
    ) 

    $WeekDay = $Index
    $Row = ''
    do {
        if ($Weekday -lt 1) {
            $Row += '{0,2} ' -f $null
        }
        else {
            $Row += '{0,2} ' -f $Weekday
        }
        $WeekDay += 7
    }
    until ($WeekDay -gt $DayPerMonth)
    
    $OutString = "$Row".PadRight(18, ' ')

    # The secret to not screwing up formatted strings with non-printable characters is to mess with the string 
    # after the string is padded to the right length.
    if ($IsThisMonth.Month -and $OutString -match "\b$($IsThisMonth.Day)\b") {
        if ($IsThisMonth.Day -lt 10) {
            $OutString = $OutString -replace "\s$($IsThisMonth.Day)\b", "$($Pretty.Day) $($IsThisMonth.Day)$($Pretty.DayReset)"
        }
        else {
            $OutString = $OutString -replace "$($IsThisMonth.Day)\b", "$($Pretty.Day)$($IsThisMonth.Day)$($Pretty.DayReset)"
        }
    }
    Write-Output $OutString
}

# Helper function for Get-Calendar - Prints one row of calendar output using the Julian Day rather than month day.

# NOTE: Some locales do not follow the Gregorian calendar and have 'unexpected' years that break ParseExact.
# Given that the Julian Day is not dependent on the year (except leap year, that's why I chose 2020), any year
# will do. This fixes the issue for now, until I find a better method.
function Get-JulianDateRow {
    Param (
        # Valid range is -5 to 1
        [Parameter(Position = 0)]
        [Int]$Index,
        
        [Parameter(Position = 1)]
        [ValidateRange(28, 31)]
        [Int]$DayPerMonth,
        
        [Parameter(Position = 2)]
        [object]$IsThisMonth,

        [Parameter(Position = 3)]
        [object]$Highlight,

        [Parameter(Position = 4)]
        [ValidateRange(1, 12)]
        [String]$Month
    )

    $WeekDay = $Index
    $Row = ''
    $PadMonth = "$Month".PadLeft(2, '0')
    do {
        if ($Weekday -lt 1) {
            $Row += '{0,3} ' -f $null
        }
        else {
            $PadDay = "$WeekDay".PadLeft(2, '0')
            $JulianDate = Get-Date ([datetime]::ParseExact("$PadDay/$PadMonth/2020", 'dd/MM/yyyy', $null)) -UFormat %j
            $Row += '{0,3} ' -f $JulianDate
        }
        $WeekDay += 7
    }
    until ($WeekDay -gt $DayPerMonth)
    
    $OutString = "$($Row.TrimEnd())".PadRight(23, ' ')
    $PadDay = "$($IsThisMonth.Day)".PadLeft(2, '0')

    if ($IsThisMonth.Month -and -not $HighLight) {
        $JulianToday = Get-Date ([datetime]::ParseExact("$PadDay/$PadMonth/2020", 'dd/MM/yyyy', $null)) -UFormat %j
        if ($OutString -match "\b$JulianToday\b") {
            $OutString = $OutString -replace "$JulianToday\b", "$($Highlight.Day)$JulianToday$($Highlight.DayReset)"
        }
    }
    Write-Output $OutString
    #Write-Verbose "|$OutString| $($OutString.Length)"
}

# Helper function for Get-Calendar that returns the first day of each required month, using current locale. Returns an 
# array of date objects.

# NOTE: ParseExact lives up to its name. It expects two digit day and month, 4 digit year.
# We need a date object here to work out the day name of the first day later (using a string fails in some cultures)
# 3rd param is culture. $null uses current culture which is what we want here. Otherwise use 
# [cultureinfo]::InvariantCulture, or more specific example [Globalization.CultureInfo]::CreateSpecificCulture('en-AU') 
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
    
    $PadMonth = "$Month".PadLeft(2, '0') 
    $TargetDate = ([datetime]::ParseExact("01/$PadMonth/$Year", 'dd/MM/yyyy', $null))
    $FirstDay = (Get-Date -Date $TargetDate).AddMonths(-$OffsetBefore)
    
    for ($i = 1; $i -le $MonthCount; $i++) {
        Write-Output $FirstDay
        $FirstDay = (Get-Date -Date $FirstDay).AddMonths(1)
    }
}

# Helper function for Get-Calendar. Returns an array. 
function Get-IsThisMonth {
    param (
        [Parameter(Position = 0)]
        [ValidateRange(1, 12)]
        [Int]$Month,
        
        [Parameter(Position = 1)]
        [ValidateRange(1000, 9999)]
        [Int]$Year
    )

    $Today = Get-Date
    if ( ($Month -eq $Today.Month) -and ($Year -eq $Today.Year) ) {
        Write-Output @{
            Month = $true
            Day   = $Today.Day
        }
    }
    else {
        Write-Output @{
            Month = $false
            Day   = $null
        }
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
    Write-Verbose "|$OutString| $($OutString.Length)"
}

function Get-Highlight {
    param (
        [ValidateSet('None', 'Red', 'Green', 'Blue', 'Yellow', 'Cyan', 'Magenta', 'White', $null)]
        [String]$Highlight
    )

    if (-Not $Highlight) {
        # Default is no heading highlight and reverse month day
        [PSCustomObject]@{
            Head      = $null
            HeadReset = $null
            Day       = $PSStyle.Reverse
            DayReset  = $PSStyle.ReverseOff  
        }
    }
    else {
        Write-Verbose "High light does equal somthing - |$highlight|"
        if ($Highlight -eq 'None') {
            Write-Output $null
        }
        else {
            $Colour = "Bright$Highlight"
            [PSCustomObject]@{
                Head      = "$($PSStyle.Foreground.$Colour)$($PSStyle.Bold)"
                HeadReset = $PSStyle.Reset
                Day       = "$($PSStyle.Background.$Colour)$($PSStyle.Foreground.Black)"
                DayReset  = $PSStyle.Reset
            }
        }
    }
}

<#
.SYNOPSIS
    Get-Calendar
.DESCRIPTION
    This command displays calendar information similar to the Linux ncal command. It implements most of the
    main functionality, including the ability to display multiple months, years, week numbers and with today 
    highlighted. 
    
    813 locales have been tested, with localised month names and day abbreviations being used. Some abbreviations 
    are of mixed length and with unicode characters. Consequently, the formatting with a few locales is messy, but 
    the command should work everywhere. 
.PARAMETER Month
    Specifies the required month. This can be specified as a number 0..12 or as the (current culture) month name
.PARAMETER Year
    Specifies the required year. If no month is specified, the whole year is shown
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
    By default, today's date is highlighted. This parameter disables this highlight.
.PARAMETER Week
    Print the number of the week below each week column
.PARAMETER JulianDay
    Display Julian days (days one-based, numbered from January 1)
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

        [ValidateSet('None', 'Red', 'Green', 'Blue', 'Yellow', 'Cyan', 'Magenta', 'White', $null)]
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

    $Pretty = Get-HighLight $Highlight

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
        $IsThisMonth = Get-IsThisMonth $ThisMonth $ThisYear

        $DayPerMonth = [DateTime]::DaysInMonth($ThisYear, $ThisMonth)
        #Write-Verbose "monthname = $MonthName, thismonth = $ThisMonth, thisyear = $ThisYear, dayspermonth = $DayPerMonth"

        if ($MonthCount -lt 4) {
            $MonthHeading += Get-MonthHeading $MonthName $ThisYear $YearSpecified $JulianSpecified
            if ($PSBoundParameters.ContainsKey($Week)) {
                $WeekRow += Get-WeekNumber $ThisMonth $ThisYear $JulianSpecified
            }  
        }
        else {
            # Print a year heading before January when year is specified
            if ($MonthHeading -match $MonthNameArray[0] -and $YearSpecified) {
                Write-Output "$ThisYear".PadLeft(39, ' ')
            }
            Write-Output "$($Pretty.Head)$MonthHeading$($Pretty.HeadReset)"
            Write-Output $MonthRow
            if ($PSBoundParameters.ContainsKey($Week)) {
                Write-Output $WeekRow
            }
            Write-Output ''
            
            # Reset for next row of 4 months
            [System.Collections.Generic.List[String]]$MonthRow = $WeekDayArray
            $MonthCount = 0
            $MonthHeading = (' ' * ($AbbrevSize + 1)) + "$(Get-MonthHeading $MonthName $ThisYear $YearSpecified $JulianSpecified)"
            if ($PSBoundParameters.ContainsKey($Week)) {
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
            if ($JulianDay) {
                $MonthRow[$_] += " $(Get-JulianDateRow $ThisIndex $DayPerMonth $IsThisMonth $Pretty $ThisMonth)"    
            }
            else {
                $MonthRow[$_] += " $(Get-DateRow  $ThisIndex $DayPerMonth $IsThisMonth $Pretty)"
            }
            $ThisIndex++
        }
        $MonthCount++
    }
    # Write the last month or months
    Write-Output "$($Pretty.Head)$MonthHeading$($Pretty.HeadReset)"
    Write-Output $MonthRow
    if ($Week) {
        Write-Output $WeekRow
    }
}