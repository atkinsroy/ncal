#Requires -Version 7.2 

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
        Saturday. All Western and Eastern European countries, Russia, Indian, Asian-Pacific countries, except China 
        and Japan follow ISO 1806 standard with Monday as the first day of the week. All North and South American 
        countries, China and Japan use Sunday.

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

        Write-Verbose "Specified/assumed First day of week is $FirstDayOfWeek"
        Write-Verbose "Cultural First day of week is $($Culture.DateTimeFormat.FirstDayOfWeek)"

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
