#Requires -Version 7.2 

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
                $HeadingLength = 29
            }
            else {
                $HeadingLength = 22
            }
            # Special cases - resorted to hard coding for double width character sets like Kanji.
            # Japanese, traditional Chinese and Korean have 1 double width character in month name, simplified Chinese 
            # and Yi have two. This is a rough hack, but it works.
            if ($Culture.Name -match '^(ja|zh-hant|ko$|ko\-)') { $HeadingLength -= 1 }
            if ($Culture.Name -match '^(zh$|zh-hans|ii)') { $HeadingLength -= 2 }
        
            # Heading length also contains additional 2 space padding, so take this into account when centering
            # Note: Padright on RTL languages makes no difference
            $Pad = $MonthName.Length + (($HeadingLength - 2 - $MonthName.Length) / 2)
            $MonthHeading = ($MonthName.PadLeft($Pad, ' ')).PadRight($HeadingLength, ' ')

        }
        # This is for ncal
        else {
            if ($true -eq $JulianSpecified) {
                $Pad = 24
            }
            else {
                $Pad = 19
            }
            # Special cases - resorted to hard coding for double width characters
            # Japanese, traditional Chinese and Korean have 1 double width character in month name, simplified Chinese 
            # and Yi have two. This is a rough hack, but it works.
            if ($Culture.Name -match '^(ja|zh-hant|ko$|ko\-)') { $Pad -= 1 }
            if ($Culture.Name -match '^(zh$|zh-hans|ii)') { $Pad -= 2 }
            $MonthHeading = "$MonthName".PadRight($Pad, ' ')
        }
        Write-Output $MonthHeading
        #Write-Verbose "|$MonthHeading| Length = $($MonthHeading.Length)"
    }
}
