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
        [Bool]$JulianSpecified,

        [Parameter(Position = 4)]
        [ValidateSet('Get-Calendar', 'Get-NCalendar')]
        [String]$Mode = 'Get-NCalendar'
    )

    begin {
        Write-Verbose "Mode is $Mode"
        $SingleDigitCulture = '^(ja|zh-hant|ko$|ko\-)'
        $DoubleDigitCulture = '^(zh$|zh-hans|ii)'
    }
    process {
        if ($Mode -eq 'Get-Calendar') {
            if ($true -eq $JulianSpecified) {
                $HeadingLength = 30
            }
            else {
                $HeadingLength = 23
            }
            # Special cases - resorted to hard coding for double width character sets like Kanji.
            # Japanese, traditional Chinese and Korean have 1 double width character in month name, simplified Chinese 
            # and Yi have two.
            if ($Culture.Name -match $SingleDigitCulture) { $HeadingLength -= 1 }
            if ($Culture.Name -match $DoubleDigitCulture) { $HeadingLength -= 2 }
            # cal month headings are centred.
            $Pad = $MonthName.Length + (($HeadingLength - 2 - $MonthName.Length) / 2)
            $MonthHeading = ($MonthName.PadLeft($Pad, ' ')).PadRight($HeadingLength, ' ')

        }
        else {
            # Get-NCalendar is the (default) calling function
            if ($true -eq $JulianSpecified) {
                $HeadingLength = 24
            }
            else {
                $HeadingLength = 19
            }
            if ($Culture.Name -match $SingleDigitCulture) { $HeadingLength -= 1 }
            if ($Culture.Name -match $DoubleDigitCulture) { $HeadingLength -= 2 }
            $MonthHeading = "$MonthName".PadRight($HeadingLength, ' ')
        }
        Write-Output $MonthHeading
    }
}
