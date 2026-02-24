function Get-Now {
    <#
    .SYNOPSIS
        Get today's date in any of the calendars supported by .NET
    .DESCRIPTION
        Displays today's date in any of the calendars supported by .NET Framework. By default, today's date for
        every supported calendar is shown. The Gregorian calendar is always shown, to compare with the specified
        calendar.
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