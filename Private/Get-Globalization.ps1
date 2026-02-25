function Get-Globalization {
    <#
    .NOTES
    This is a helper function for Get-NCalendar and Get-Calendar to determine the culture and calendar objects,
    for either the specified calendar or culture string.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Calendar,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Culture
    )

    begin {
        # Assume week rows are supported (ncal only and only for some calendar types)
        $IgnoreWeekRow = $false
    }

    process {
        if ($null -ne $Culture -and '' -ne $Culture) {
            try {
                $ThisCulture = New-Object System.Globalization.CultureInfo($Culture) -ErrorAction Stop
                # The above doesn't always capture unsupported culture so test further
                $AllCulture = (Get-Culture -ListAvailable).Name
                if ($Culture -notin $AllCulture) {
                    Write-Warning "Invalid culture specified: '$Culture'. Using the system default culture ($((Get-Culture).Name)). Use 'Get-Culture -ListAvailable'."
                    $ThisCulture = [System.Globalization.CultureInfo]::CurrentCulture
                } 
            }
            catch {
                Write-Warning "Invalid culture specified: '$Culture'. Using the system default culture ($((Get-Culture).Name)). Use 'Get-Culture -ListAvailable'."
                $ThisCulture = [System.Globalization.CultureInfo]::CurrentCulture
            }
            $ThisCalendar = $ThisCulture.Calendar
        }
        elseif ($null -ne $Calendar -and '' -ne $Calendar) {
            $CultureLookup = @{
                'Gregorian'         = 'en-AU'
                'Persian'           = 'fa-IR'
                'Hijri'             = 'ar-SA'
                'Hebrew'            = 'he-IL'
                'Japanese'          = 'ja-JP'
                'Korean'            = 'ko-KR'
                'Taiwan'            = 'zh-Hant-TW'
                'UmAlQura'          = 'ar-SA'
                'ThaiBuddhist'      = 'th-TH'
                'Julian'            = 'en-AU'
                'ChineseLunisolar'  = 'zh'
                'JapaneseLunisolar' = 'ja'
                'KoreanLunisolar'   = 'ko'
                'TaiwanLunisolar'   = 'zh-Hant-TW'
            }
            <#
                In order to support Julian and Asian Lunar calendars ('non-optional'), treat culture and calendar
                separately. With optional calendars you can set the culture to use them, but this doesn't work for
                the above.
            #>
            $ThisCulture = New-Object System.Globalization.CultureInfo($($CultureLookup[$Calendar]))
            $ThisCalendar = New-Object "System.Globalization.$($Calendar)Calendar"

            # When a user specifies a calendar, some of them don't support week rows.
            $IgnoreCalendar = @(
                'Hijri',
                'Hebrew',
                'Julian',
                'ChineseLunisolar',
                'JapaneseLunisolar',
                'KoreanLunisolar',
                'TaiwanLunisolar'
            )
            if ( $Calendar -in $IgnoreCalendar) {
                $IgnoreWeekRow = $true
            }
        }
        else {
            $ThisCulture = [System.Globalization.CultureInfo]::CurrentCulture
            $ThisCalendar = $ThisCulture.Calendar
        }
        [PSCustomObject]@{
            Culture       = $ThisCulture
            Calendar      = $ThisCalendar
            IgnoreWeekRow = $IgnoreWeekRow
        }
    }
}