#Requires -Version 7.2 

function Get-Highlight {
    <# 
    .NOTES
        Helper function for Get-NCalendar and Get-Calendar. Returns an array with todays day if it is today as well
        as formatting strings.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Globalization.CultureInfo]$Culture,

        [Parameter(Mandatory, Position = 1)]
        [ValidateRange(1, 12)]
        [Int]$Month,
        
        [Parameter(Mandatory, Position = 2)]
        [ValidateRange(1000, 9999)]
        [Int]$Year,

        [Parameter(Position = 3)]
        [ValidateSet('None', 'Red', 'Green', 'Blue', 'Yellow', 'Cyan', 'Magenta', 'White', 'Orange', $null)]
        [String]$Highlight
    )
    $Now = Get-Today -Culture $Culture
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