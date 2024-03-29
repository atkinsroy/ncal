#Requires -Version 7.2 

# Helper function for Get-NCalendar - Prints one row of calendar output, given an Index corresponding to the first 
# day of the month.
function Get-NcalRow {
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
    $JulianDay = 0

    if ($JulianSpecified) {
        $PadRow = 24
        $PadDay = 3
    }
    else {
        $PadRow = 19
        $PadDay = 2
    }

    do {
        if ($WeekDay -lt 1) {
            $Row += "{0,$PadDay} " -f $null
        }
        else {
            if ($JulianSpecified) {
                $Row += "{0,$PadDay} " -f (Get-Date ([datetime]::new($Year, $Month , $WeekDay )) -UFormat %j)
            }
            else {
                $Row += "{0,$PadDay} " -f $WeekDay
            }
        }
        $WeekDay += 7
    }
    until ($WeekDay -gt $DayPerMonth)
    
    $OutString = "$($Row.TrimEnd())".PadRight($PadRow, ' ')
    
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

# Helper function for Get-Calendar - Prints one row of calendar output, given an Index corresponding to the first day of the month.
function Get-CalRow {
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
    $JulianDay = 0

    if ($JulianSpecified) {
        $PadRow = 29
        $PadDay = 3
    }
    else {
        $PadRow = 22
        $PadDay = 2
    }

    # Repeat 7 times for each week day in the row 
    0..6 | ForEach-Object {
        if ($WeekDay -lt 1) {
            $Row += "{0,$PadDay} " -f $null
        }
        elseif ($WeekDay -gt $DayPerMonth) {
            # Do nothing
        }
        else {
            if ($JulianSpecified) {
                $Row += "{0,$PadDay} " -f (Get-Date ([datetime]::new($Year, $Month , $WeekDay )) -UFormat %j)
            }
            else {
                $Row += "{0,$PadDay} " -f $WeekDay
            }
        }
        $WeekDay++
    }
    
    $OutString = "$($Row.TrimEnd())".PadRight($PadRow, ' ')
    
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

# Helper function for Get-NCalendar and Get-Calendar that returns the first day of each required month, using current locale. 
# Returns an array of date objects.
function Get-FirstDayOfMonth {
    Param (
        [Parameter(Position = 0)]
        [ValidateRange(1, 12)]
        [Int]$Month,
        
        [Parameter(Position = 1)]
        [ValidateRange(1000, 9999)]
        [Int]$Year,
        
        [Parameter(Position = 2)]
        [Int]$BeforeOffset,
        
        [Parameter(Position = 3)]
        [Int]$AfterOffset
    )
    $MonthCount = 1 + $BeforeOffset + $AfterOffset
    $TargetDate = [datetime]::new($Year, $Month, 1)
    $FirstDay = (Get-Date -Date $TargetDate).AddMonths(-$BeforeOffset)
    
    for ($i = 1; $i -le $MonthCount; $i++) {
        Write-Output $FirstDay
        $FirstDay = (Get-Date -Date $FirstDay).AddMonths(1)
    }
}

# Helper function for Get-NCalendar and Get-Calendar. Returns a string.
function Get-MonthHeading {
    param (
        [Parameter(Position = 0)]
        [String]$MonthName,
        
        [Parameter(Position = 1)]
        [Int]$ThisYear,
        
        [Parameter(Position = 2)]
        [bool]$YearSpecified,

        [Parameter(Position = 3)]
        [bool]$JulianSpecified,

        [parameter(Position = 4)]
        [Switch]$Centred
    )

    # When year is not specified, append the year to month heading
    # for Right to left languages, like Hebrew, Arabic, Farsi and Urdu, formatting is screwed up when mixing 
    # latin letters, so don't show year with month. This exhibits the best result for Windows Terminal and VS Code 
    # terminal right now, given the current RTL language support.
    if ($YearSpecified) {
        $FullMonthName = $MonthName 
    }
    elseif ((Get-Culture).Name -match '^(ar$|ar\-|ckb$|ckb\-|fa$|fa\-|he$|he\-|ks$|ks\-|lrc\-iq|pa\-arab|ps$|ps\-|sd$|sd\-|sy$|sy\-|ug$|ug\-|ur$|ur\-|yi$|yi\-)') {
        $FullMonthName = "$MonthName"
    }
    else {
        $FullMonthName = "$MonthName $ThisYear"
    }

    # Centred means this is for the cal function
    if ($Centred) {
        if ($JulianSpecified) {
            $HeadingLength = 29
        }
        else {
            $HeadingLength = 22
        }
        # Special cases - resorted to hard coding for double width character sets like Kanji.
        # Japanese, traditional Chinese and Korean have 1 double width character in month name, simplified Chinese 
        # and Yi have two.
        if ((Get-Culture).Name -match '^(ja|zh-hant|ko$|ko\-)') { $HeadingLength -= 1 }
        if ((Get-Culture).Name -match '^(zh$|zh-hans|ii)') { $HeadingLength -= 2 }
        
        # Heading length also contains additional 2 space padding, so take this into account when centering
        # Note: Padright on RTL languages makes no difference
        $Pad = $FullMonthName.Length + (($HeadingLength - 2 - $FullMonthName.Length) / 2)
        $MonthHeading = ($FullMonthName.PadLeft($Pad, ' ')).PadRight($HeadingLength, ' ')

    }
    # This is for ncal
    else {
        if ($JulianSpecified) {
            $Pad = 24
        }
        else {
            $Pad = 19
        }
        # Special cases - resorted to hard coding for double width characters
        # Japanese, traditional Chinese and Korean have 1 double width character in month name, simplified Chinese 
        # and Yi have two.
        if ((Get-Culture).Name -match '^(ja|zh-hant|ko$|ko\-)') { $Pad -= 1 }
        if ((Get-Culture).Name -match '^(zh$|zh-hans|ii)') { $Pad -= 2 }
        $MonthHeading = "$FullMonthName".PadRight($Pad, ' ')
    }
    Write-Output $MonthHeading
    Write-Verbose "|$MonthHeading| Length = $($MonthHeading.Length)"
}

# Helper function for Get-NCalendar. Prints the week number to display beneath each column

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
    $FirstDate = [datetime]::new($Year, $Month , 1 )
    [Int]$FirstWeek = Get-Date -Date $FirstDate -UFormat %V
    [String]$WeekRow = ''
    [Int]$WeekCount = 4

    if ($JulianSpecified) {
        $PadRow = 24
        $PadDay = 3
    }
    else {
        $PadRow = 19
        $PadDay = 2
    }
    
    $LastWeek = $FirstWeek + $WeekCount
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
    Write-Verbose "|$OutString| Week row length $($OutString.Length)"
}

# Helper function for Get-NCalendar and Get-Calendar. Returns an array with todays day if it is today as well 
# as formatting strings.
# NOTE: With some islamic locales like ps (Pashto) and ar-SA (Saudi Arabic), the islamic calendar is followed.
# (Get-Date).Year - wrong, provides western year.
# Get-Date -format 'yyyy' - right. Same for month and day.
function Get-Highlight {
    param (
        [Parameter(Position = 0)]
        [ValidateRange(1, 12)]
        [Int]$Month,
        
        [Parameter(Position = 1)]
        [ValidateRange(1000, 9999)]
        [Int]$Year,

        [Parameter(Position = 2)]
        [ValidateSet('None', 'Red', 'Green', 'Blue', 'Yellow', 'Cyan', 'Magenta', 'White', 'Orange', $null)]
        [String]$Highlight
    )

    [int]$TodayDay = Get-Date -Format 'dd'
    [int]$TodayMonth = Get-Date -Format 'MM'
    [int]$TodayYear = Get-Date -Format 'yyyy'
    if ( ($Month -eq $TodayMonth) -and ($Year -eq $TodayYear) ) {
        $Today = $TodayDay
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
        elseif ($Highlight -eq 'Orange') {
            # Just for giggles, a non-PSStyle supplied colour
            Write-Output @{
                Today    = $Today
                MonStyle = "$($PSStyle.Foreground.FromRgb(255,131,0))$($PSStyle.Bold)"
                MonReset = $PSStyle.Reset
                DayStyle = "$($PSStyle.Background.FromRgb(255,131,0))$($PSStyle.Foreground.FromRgb(0,0,0))"
                DayReset = $PSStyle.Reset
            }
        }
        else {
            # Force "bright" version of the specified colour
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
    Get-NCalendar
.DESCRIPTION
    This command displays calendar information similar to the Linux ncal command. It implements most of the
    main functionality, including the ability to display multiple months, years, week numbers, julian day and 
    highlights for the current day.
    
    813 locales have been tested, with localized month names and day abbreviations being used. Locales using unicode
    character sets should work providing an appropriate font is used in the terminal.
    
    Locales following the Islamic calendar work. This begins at year 1 "Anno Hegirae", or 622 A.D. in Gregorian 
    calendar, so 2021 is 1400 for some locales. For example most of the Iranain locales and some Arabic locales.
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
    By default, today's date is highlighted. Specify a colour or disable the default highlight with 'none'.
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
    -------------------------- 
    1. -C to switch to 'cal mode', 
    2. -J Julian Calendar and other Julian Calendar support e.g -p and -s, -o and -e to Easter for 
       Orthodox and Western Churches resp.
    3. passing specific dates and highlight dates for debug purposes

    Deviating ncal functionality:
    ----------------------------
    1. With Linux ncal, You can use -y with -B and -A, but -3 and -m 6p (and f) are ignored. With this version 
       of ncal, -before, -after and -month 6p (and f) all work with -year. -Three is ignored as with the Linux version.
    2. Linux ncal has a bug. -m 1p shows January this year (so its same as -m 1). With this version of ncal -month 1p
       correctly shows January last year.
#>
function Get-NCalendar {
    [Alias('ncal')]
    [CmdletBinding()]
    param(
        # Normal PowerShell validation of month is tricky because of month name locale support and the need to accept month numbers 
        [Parameter(Position = 0)]
        [Alias('m')]
        [String]$Month,
        
        [Parameter(Position = 1)]
        [ValidateRange(1000, 9999)]
        [Int]$Year,

        [Int]$Before,

        [Int]$After,

        [Switch]$Three,

        [ValidateSet('None', 'Red', 'Green', 'Blue', 'Yellow', 'Cyan', 'Magenta', 'White', 'Orange')]
        [String]$Highlight,

        [Switch]$Week,

        [Switch]$JulianDay,

        [Switch]$FirstDayMonday,

        [Switch]$FullDayName,

        [ValidateRange(1, 6)]
        [int]$MonthPerRow = 4
    )

    $YearSpecified = $false

    # Determine week day names - This section of code is probably far more complex than it needs to be...
    # Note: There are globalisation issues with attempting to truncate day names in some cultures, so only truncate 
    # cultures with standard character sets.
    # Note: $MonthOffset is an attempt to fix column formats with many cultures that have mixed length short and 
    # long day names. It seems to work ok providing an appropriate font is installed supporting unicode characters.
    if ($PSBoundParameters.ContainsKey('FullDayName')) {
        $WeekDayArray = [cultureinfo]::CurrentCulture.DateTimeFormat.DayNames
        if ((Get-Culture).Name -match '^(ja|zh|ko$|ko\-|ii)') {
            # Full day name for cultures that use double width character sets, double the size of the month offset but not the weekday  
            $MonthOffset = 1 + (($WeekDayArray | ForEach-Object { "$_".Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum) * 2)
            $WeekDayLength = $WeekDayArray | ForEach-Object { "$_".Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
            $WeekDayArray = $WeekDayArray | ForEach-Object { "$_".PadRight($WeekDayLength + 1, ' ') }
        }
        else {
            # Full day name for cultures using latin and Persian character sets. Support for Persian is so broken, so don't even try.
            $MonthOffset = 2 + ($WeekDayArray | ForEach-Object { "$_".Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum)
            $WeekDayArray = $WeekDayArray | ForEach-Object { "$_".PadRight($MonthOffset - 1, ' ') }
        }

    }
    else {
        # Simulate the Linux ncal command with two character day names on some Western cultures. I have not done 
        # exhaustive testing. Some cultures a probably missing here.
        if ((Get-Culture).Name -match '^(en|fr|it|es|eo)') {
            $WeekDayArray = [cultureinfo]::CurrentCulture.DateTimeFormat.AbbreviatedDayNames | ForEach-Object { "$_".Substring(0, 2).PadRight(3, ' ') }
            $MonthOffset = 4
        }
        else {
            $WeekDayArray = [cultureinfo]::CurrentCulture.DateTimeFormat.AbbreviatedDayNames
            if ((Get-Culture).Name -match '^(ja|zh|ko$|ko\-|ii)') {
                # Short day names for cultures that use double width character sets
                $MonthOffset = 2 + (($WeekDayArray | ForEach-Object { "$_".Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum) * 2)
                $WeekDayLength = $WeekDayArray | ForEach-Object { "$_".Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
                $WeekDayArray = $WeekDayArray | ForEach-Object { "$_".PadRight($WeekDayLength + 1, ' ') }
            }
            else {
                # Short day name for all other cultures. 
                $MonthOffset = 2 + ($WeekDayArray | ForEach-Object { "$_".Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum)
                $WeekDayArray = $WeekDayArray | ForEach-Object { "$_".PadRight($MonthOffset - 1, ' ') }
            }
        }
    }
    # $WeekDayArray | % { Write-Verbose "|$_|" }
    #Write-Verbose "MonthOffset is $MonthOffset"

    # Full month names in current culture
    $MonthNameArray = [cultureinfo]::CurrentCulture.DateTimeFormat.MonthGenitiveNames

    # Parameter validation starts here
    if ($PSBoundParameters.ContainsKey('FirstDayMonday')) {
        # Note: CultureInfo .Net type defaults to Sunday as start of week. This is different to Linux style -UFormat, which is Monday.
        $WeekDayArray = (1..6 | ForEach-Object { $WeekDayArray[$_] }) + $WeekDayArray[0]
    }

    if ($PSBoundParameters.ContainsKey('JulianDay')) {
        [bool]$JulianSpecified = $true
    }
    else {
        [bool]$JulianSpecified = $false
    }

    if ($PSBoundParameters.ContainsKey('Month')) {
        [int]$AfterOffset = 0
        [int]$AfterOffset = 0

        # this method honours Islamic locales, (Get-Date).Year does not. So 2022 is 1401 in the Persian calendar, for example.
        if (-Not $PSBoundParameters.ContainsKey('Year')) { 
            [int]$Year = Get-Date -Format 'yyyy'
        }
    
        # User specifies a month expressed as an integer
        if ($Month -in 1..12) {
            [int]$MonthNumber = $Month
        }
        # User specifies a month name in the local culture
        elseif ($Month.Length -gt 2 -and $MonthNameArray -match $Month) {
            [string]$MonthName = $MonthNameArray -match $Month
            [int]$MonthNumber = ([cultureinfo]::CurrentCulture.DateTimeFormat.MonthGenitiveNames).IndexOf("$MonthName") + 1
        }
        #trailing 'f' means month specified but forward 1 year
        elseif ($Month -match '^(0?[1-9]|1[0-2])[Ff]$') {
            [int]$MonthNumber = ($Month | Select-String -Pattern '^\d+').Matches.Value
            $Year += 1
        }
        #trailing 'p' means month specified previous 1 year
        elseif ($Month -match '^(0?[1-9]|1[0-2])[Pp]$') {
            [int]$MonthNumber = ($Month | Select-String -Pattern '^\d+').Matches.Value
            $Year -= 1
        }
        else {
            throw "ncal: '$Month' is neither a month number (1..12) nor a valid month name (using the current culture)"
        }
    }
    else {
        # No month
        if ($PSBoundParameters.ContainsKey('Year')) {
            # Year specified with no month; showing whole year
            [int]$MonthNumber = 1
            [int]$BeforeOffset = 0
            [int]$AfterOffset = 11
            [bool]$YearSpecified = $true
        }
        else {
            # Default is this month only
            [int]$MonthNumber = Get-Date -Format 'MM'
            [int]$Year = Get-Date -Format 'yyyy'
        }
    }

    # add additional month before and after current month. 
    if ($PSBoundParameters.ContainsKey('Three') -and -not $YearSpecified) {
        [int]$BeforeOffset = 1
        [int]$AfterOffset = 1
    }
    # add specified number of months before the month or year already identified
    if ($PSBoundParameters.ContainsKey('Before')) {
        $BeforeOffset += $Before
    }
    # add specified number of months following the month(s) or year already identified
    if ($PSBoundParameters.ContainsKey('After')) {
        $AfterOffset += $After
    }
    # Parameter validation end

    # Get the date of the first day of each required month
    $MonthList = Get-FirstDayOfMonth $MonthNumber $Year $BeforeOffset $AfterOffset
    #$MonthList | ForEach-Object { Write-Verbose "|$_|" }

    # To hold each row for 1 to 4 months, initialized with culture specific day abbreviation
    [System.Collections.Generic.List[String]]$MonthRow = $WeekDayArray

    $MonthCount = 0
    $MonthHeading = ' ' * $MonthOffset
    $WeekRow = ' ' * ($MonthOffset - 1)
    $Calendar = ("$([cultureinfo]::CurrentCulture.DateTimeFormat.Calendar)" -split '\.')[2]
    
    foreach ($RequiredMonth in $MonthList) {
        # $RequiredMonth contains the date of the first day of the month to display
        $ThisMonth = $RequiredMonth.Month
        $ThisYear = $RequiredMonth.Year
        $MonthName = $MonthNameArray[$ThisMonth - 1]  # MonthNameArray is zero based
        
        # for highlighting today
        $Pretty = Get-Highlight $ThisMonth $ThisYear $Highlight

        $DayPerMonth = [DateTime]::DaysInMonth($ThisYear, $ThisMonth)
        Write-Verbose "monthname = $MonthName, thismonth = $ThisMonth, thisyear = $ThisYear, dayspermonth = $DayPerMonth, calendar=$Calendar"

        if ($PSBoundParameters.ContainsKey('FirstDayMonday')) {
            # Week starts Monday by default with -Uformat %u. Here we need Monday = 1 thru Sunday = -5
            $ThisIndex = 2 - (Get-Date $RequiredMonth -UFormat %u)
        }
        else {
            # Week starts Sunday - Monday = 0 thru Sunday = -6, which would mean start of next column, so force Sunday to be 1
            $ThisIndex = 1 - (Get-Date $RequiredMonth -UFormat %u)
            if ($ThisIndex -eq -6) { $ThisIndex = 1 }
        }

        if ($MonthCount -lt $MonthPerRow) {
            $MonthHeading += "$(Get-MonthHeading $MonthName $ThisYear $YearSpecified $JulianSpecified)"
            if ($PSBoundParameters.ContainsKey('Week')) {
                $WeekRow += Get-WeekNumber $ThisMonth $ThisYear $JulianSpecified
            }  
        }
        else {
            # Print a year heading before January when year is specified (3 weekday length - 2 additional spaces)
            if ($MonthHeading -match $MonthNameArray[0] -and $YearSpecified) {
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
            [System.Collections.Generic.List[String]]$MonthRow = $WeekDayArray
            $MonthCount = 0
            $MonthHeading = (' ' * $MonthOffset) + "$(Get-MonthHeading $MonthName $ThisYear $YearSpecified $JulianSpecified)"
            if ($PSBoundParameters.ContainsKey('Week')) {
                $WeekRow = (' ' * $MonthOffset) + "$(Get-WeekNumber $ThisMonth $ThisYear $JulianSpecified)"
            }
        }

        0..6 | ForEach-Object {
            $MonthRow[$_] += "$(Get-NcalRow  $ThisIndex $DayPerMonth $ThisMonth $Year $JulianSpecified $Pretty)"
            $ThisIndex++
        }
        $MonthCount++
    }
    # Write the last month or months
    # Print a year heading before January when year is specified
    if ($MonthHeading -match $MonthNameArray[0] -and $YearSpecified) {
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

<#
.SYNOPSIS
    Get-Calendar
.DESCRIPTION
    This command displays calendar information similar to the Linux cal command. It implements most of the
    main functionality, including the ability to display multiple months, years, julian day and highlights for the 
    current day.
    
    813 locales have been tested, with localized month names and day abbreviations being used. Locales using unicode
    character sets should work providing an appropriate font is used in the terminal.
    
    Locales following the Islamic calendar work. This begins at year 1 "Anno Hegirae", or 622 A.D. in Gregorian 
    calendar, so 2021 is 1400 for some locales. For example most of the Iranain locales and some Arabic locales.
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
    By default, today's date is highlighted. Specify a colour or disable the default highlight with 'none'.
.PARAMETER JulianDay
    Display Julian days (days one-based, numbered from 1st January)
.PARAMETER FirstDayMonday
    Display Monday as the first day of the week. By default, this is Sunday.
.EXAMPLE
    PS C:\> cal
    
    Displays this month
.EXAMPLE
    PS C:\> cal -y 2021
    
    Displays each month of the specified year
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
.INPUTS
    [System.String]
    [System.Int]
.OUTPUTS
    [System.String]
.NOTES
    Author: Roy Atkins
#>
function Get-Calendar {
    [Alias('cal')]
    [CmdletBinding()]
    param(
        # Normal PowerShell validation of month is tricky because of month name locale support and the need to accept month numbers
        [Parameter(Position = 0)]
        [Alias('m')]
        [String]$Month,
        
        [Parameter(Position = 1)]
        [ValidateRange(1000, 9999)]
        [Int]$Year,

        [Int]$Before,

        [Int]$After,

        [Switch]$Three,

        [ValidateSet('None', 'Red', 'Green', 'Blue', 'Yellow', 'Cyan', 'Magenta', 'White', 'Orange')]
        [String]$Highlight,

        [Switch]$JulianDay,

        [Switch]$FirstDayMonday,

        [ValidateRange(1, 6)]
        [int]$MonthPerRow = 3
    )

    $YearSpecified = $false

    # Determine day names
    # Note: There are globalisation issues with attempting to truncate day names in some cultures, so use full PowerShell day name
    if ((Get-Culture).Name -match '^(en|fr|it|es|eo)') {
        $WeekDayArray = [cultureinfo]::CurrentCulture.DateTimeFormat.AbbreviatedDayNames | ForEach-Object { "$_".Substring(0, 2) }
    }
    else {
        # Some cultures use double width charecter sets. So attempt to capture these and do not pad day names
        if ((Get-Culture).Name -match '^(ja|zh|ko$|ko\-|ii)') {  
            $WeekDayArray = [cultureinfo]::CurrentCulture.DateTimeFormat.ShortestDayNames
        }
        else {
            $WeekDayArray = [cultureinfo]::CurrentCulture.DateTimeFormat.ShortestDayNames | ForEach-Object { "$_".PadLeft(2, ' ') }
        }
    }

    # Full month names in current culture, e.g. January, February
    $MonthNameArray = [cultureinfo]::CurrentCulture.DateTimeFormat.MonthGenitiveNames

    # Parameter validation starts here
    if ($PSBoundParameters.ContainsKey('FirstDayMonday')) {
        # Note: CultureInfo .Net type defaults to Sunday as start of week. This is different to Linux style -UFormat, which is Monday.
        $WeekDayArray = (1..6 | ForEach-Object { $WeekDayArray[$_] }) + $WeekDayArray[0]
    }

    if ($PSBoundParameters.ContainsKey('JulianDay')) {
        [bool]$JulianSpecified = $true
        $WeekDayArray = $WeekDayArray | ForEach-Object { "$_".PadRight(3, ' ') }
        $WeekDayArray += ' '
    }
    else {
        [bool]$JulianSpecified = $false

        # Trial and error to get as many locales behaving as expected.
        if ("$WeekDayArray".Length -le 20) {
            $WeekDayArray += ' '
        }
    }

    if ($PSBoundParameters.ContainsKey('Month')) {
        [int]$AfterOffset = 0
        [int]$AfterOffset = 0

        # this method honours Islamic locales, (Get-Date).Year does not. So 2022 is 1401 for example.
        if (-Not $PSBoundParameters.ContainsKey('Year')) { 
            [int]$Year = Get-Date -Format 'yyyy'
        }
    
        # User specifies a month expressed as an integer
        if ($Month -in 1..12) {
            [int]$MonthNumber = $Month
        }
        # User specifies a month name in the local culture
        elseif ($Month.Length -gt 2 -and $MonthNameArray -match $Month) {
            [string]$MonthName = $MonthNameArray -match $Month
            [int]$MonthNumber = ([cultureinfo]::CurrentCulture.DateTimeFormat.MonthGenitiveNames).IndexOf("$MonthName") + 1
        }
        #trailing 'f' means month specified but forward 1 year
        elseif ($Month -match '^(0?[1-9]|1[0-2])[Ff]$') {
            [int]$MonthNumber = ($Month | Select-String -Pattern '^\d+').Matches.Value
            $Year += 1
        }
        #trailing 'p' means month specified previous 1 year
        elseif ($Month -match '^(0?[1-9]|1[0-2])[Pp]$') {
            [int]$MonthNumber = ($Month | Select-String -Pattern '^\d+').Matches.Value
            $Year -= 1
        }
        else {
            throw "cal: '$Month' is neither a month number (1..12) nor a valid month name (using the current culture)"
        }
    }
    else {
        # No month
        if ($PSBoundParameters.ContainsKey('Year')) {
            # Year specified with no month; showing whole year
            [int]$MonthNumber = 1
            [int]$BeforeOffset = 0
            [int]$AfterOffset = 11
            [bool]$YearSpecified = $true
        }
        else {
            # Default is this month only
            [int]$MonthNumber = Get-Date -Format 'MM'
            [int]$Year = Get-Date -Format 'yyyy'
        }
    }

    # add additional month before and after current month.
    if ($PSBoundParameters.ContainsKey('Three') -and -not $YearSpecified) {
        [int]$BeforeOffset = 1
        [int]$AfterOffset = 1
    }
    # add specified number of months before the month or year already identified
    if ($PSBoundParameters.ContainsKey('Before')) {
        $BeforeOffset += $Before
    }
    # add specified number of months following the month or year already identified
    if ($PSBoundParameters.ContainsKey('After')) {
        $AfterOffset += $After
    }
    # Parameter validation end

    # Get the date of the first day of each required month
    $MonthList = Get-FirstDayOfMonth $MonthNumber $Year $BeforeOffset $AfterOffset

    # To hold each row for 1 to 4 months, initialized with culture specific day abbreviation
    $MonthRow = New-Object string[] 7  # initialize a strongly typed, fixed length array with no values
    $MonthCount = 0
    $MonthHeading = ''
    
    foreach ($RequiredMonth in $MonthList) {
        # $RequiredMonth contains the date of the first day of the month to display
        $ThisMonth = $RequiredMonth.Month
        $ThisYear = $RequiredMonth.Year
        $MonthName = $MonthNameArray[$ThisMonth - 1]
        
        # for highlighting today
        $Pretty = Get-Highlight $ThisMonth $ThisYear $Highlight

        $DayPerMonth = [DateTime]::DaysInMonth($ThisYear, $ThisMonth)
        Write-Verbose "monthname = $MonthName, thismonth = $ThisMonth, thisyear = $ThisYear, dayspermonth = $DayPerMonth, monthcount = $MonthCount"

        if ($PSBoundParameters.ContainsKey('FirstDayMonday')) {
            # Week starts Monday by default with -Uformat %u. Here we need Monday = 1 thru Sunday = -5
            $ThisIndex = 2 - (Get-Date $RequiredMonth -UFormat %u)
        }
        else {
            # Week starts Sunday - Monday = 0 thru Sunday = -6, which would mean start of next column, so force Sunday to be 1
            $ThisIndex = 1 - (Get-Date $RequiredMonth -UFormat %u)
            if ($ThisIndex -eq -6) { $ThisIndex = 1 }
        }

        if ($MonthCount -lt $MonthPerRow) {
            $MonthHeading += Get-MonthHeading $MonthName $ThisYear $YearSpecified $JulianSpecified -Centred
        }
        else {
            # Print a year heading before January when year is specified
            if ($MonthHeading -match $MonthNameArray[0] -and $YearSpecified) {
                $YearPad = (((22 * $MonthPerRow) - 2 ) / 2) + 2 
                $YearHeading = "$ThisYear".PadLeft($YearPad, ' ')
                Write-Output "$($Pretty.MonStyle)$YearHeading$($Pretty.MonReset)"
            }
            # Print the next row of required months
            Write-Output "$($Pretty.MonStyle)$MonthHeading$($Pretty.MonReset)"
            Write-Output $MonthRow
            Write-Output ''
            
            # Reset for next row of 3 months
            $MonthRow = New-Object string[] 7  # initialize a strongly typed, fixed length array with no values
            $MonthCount = 0
            $MonthHeading = Get-MonthHeading $MonthName $ThisYear $YearSpecified $JulianSpecified -Centred
        }

        $MonthRow[0] += "$WeekDayArray"
        Write-Verbose "|$WeekDayArray| Length = $("$WeekDayArray".Length)"

        1..6 | ForEach-Object {
            $MonthRow[$_] += "$(Get-CalRow  $ThisIndex $DayPerMonth $ThisMonth $Year $JulianSpecified $Pretty)"
            $ThisIndex += 7
        }
        $MonthCount++
    }
    # Write the last month or months
    # Print a year heading before January when year is specified
    if ($MonthHeading -match $MonthNameArray[0] -and $YearSpecified) {
        $YearPad = (((22 * $MonthPerRow) - 2 ) / 2) + 2 
        $YearHeading = "$ThisYear".PadLeft($YearPad, ' ')
        Write-Output "$($Pretty.MonStyle)$YearHeading$($Pretty.MonReset)"
    }
    Write-Output "$($Pretty.MonStyle)$MonthHeading$($Pretty.MonReset)"
    Write-Output $MonthRow
}