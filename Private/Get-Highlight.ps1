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
        [ValidateSet('None', 'Red', 'Green', 'Blue', 'Yellow', 'Cyan', 'Magenta', 'White', 'Orange', 'Pink', $null)]
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
        # Just for giggles, demonstrate some non-PSStyle supplied colours
        elseif ('Orange' -eq $Highlight) {
            Write-Output @{
                Today    = $Today
                MonStyle = "$($PSStyle.Foreground.FromRgb(255,131,0))$($PSStyle.Bold)"
                MonReset = $PSStyle.Reset
                DayStyle = "$($PSStyle.Background.FromRgb(255,131,0))$($PSStyle.Foreground.FromRgb(0,0,0))"
                DayReset = $PSStyle.Reset
            }
        }
        elseif ('Pink' -eq $Highlight) {
            Write-Output @{
                Today    = $Today
                MonStyle = "$($PSStyle.Foreground.FromRgb(255,0,255))$($PSStyle.Bold)"
                MonReset = $PSStyle.Reset
                DayStyle = "$($PSStyle.Background.FromRgb(255,0,255))$($PSStyle.Foreground.FromRgb(0,0,0))"
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