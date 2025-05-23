---
external help file: ncal-help.xml
Module Name: ncal
online version: https://github.com/atkinsroy/ncal/docs
schema: 2.0.0
---

# Get-Calendar

## SYNOPSIS

Get-Calendar

## SYNTAX

### UseCulture (Default)

```PowerShell
Get-Calendar [[-Month] <String>] [[-Year] <Int32>] [[-Culture] <String>] [[-FirstDayOfWeek] <String>]
 [[-MonthPerRow] <Int32>] [[-Highlight] <String>] [-Before <Int32>] [-After <Int32>] [-Three] [-DayOfYear]
 [-Name] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### UseCalendar

```PowerShell
Get-Calendar [[-Month] <String>] [[-Year] <Int32>] [[-Calendar] <String>] [[-FirstDayOfWeek] <String>]
 [[-MonthPerRow] <Int32>] [[-Highlight] <String>] [-Before <Int32>] [-After <Int32>] [-Three] [-DayOfYear]
 [-Name] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

This command displays calendar information similar to the Linux cal command.It implements the same functionality,
including the ability to display multiple months, years, day of the year and month forward and month previous by
one year.

But in addition, the command can do a whole lot more:

1. Display a calendar in any supported culture.Month and day names are displayed in the appropriate language for
the specified culture and the appropriate calendar is used (e.g. Gregorian, Persian), along with appropriate
DateTimeFormat information (e.g. default first day of the week).
2. As well as display the primary calendar (used by each culture), also display optional calendars. These are
Hijri, Hebrew, Japanese (Solar), Korean (Solar) and Taiwanese (Solar) calendars. In addition, the non-optional
calendars.
These are the Julian and Chinese, Japanese, Korean and Taiwanese Lunar calendars. (Note: Only the current era is
supported).
3. Specify the first day of the week (Friday through Monday). The specified or current culture setting is used by
default. Friday through Monday are supported because all cultures use one of these days.
4. Display one to six months in a row, when multiple months are displayed (the default is 3).
5. Highlight the year and month headings and todays date using a specified colour.

It is highly recommended that Windows Terminal is used with an appropriate font to ensure that ISO unicode
character sets are both available and are displayed correctly. With other consoles, like Visual Studio Code,
the ISE and the default PowerShell console, some fonts might not display correctly and with extended unicode
character sets, calendars may appear misaligned.

Note: From version 1.22.10352.0 (Feb 2025) of Windows Terminal, grapheme clusters are now supported and are turned
on by default. A grapheme cluster is a single user-perceived character made up of multiple code points from the
Unicode Standard, introduced in .NET 5. Whilst this is considered the correct method for handling and displaying
Unicode character sets, PowerShell doesn't support grapheme clusters and thus, calandars in ncal appear misaligned.
This can be remedied, in the short term, by disabling grapheme cluster support in Settings \>
Compatibility \> Text measurement mode, selecting "Windows Console" and then restarting the Windows Terminal.

## EXAMPLES

### EXAMPLE 1

```PowerShell
cal
```

Displays this month using the current culture

### EXAMPLE 2

```PowerShell
cal -m 1 -a 11 -culture fa
```

Displays the first month and the following 11 months (this year) for any specified culture. For example, -Year 2025
with cultures that do not use the Gregorian calendar by default will not work or produce unintended results.
Some cultures use the Persian (Iranian), ThaiBuddist and UmAlQura (Umm al-Qura, Saudi Arabian) calendars by default.

### EXAMPLE 3

```PowerShell
cal -m 1f
```

Displays January next year.
-m 4p shows April from the previous year

### EXAMPLE 4

```PowerShell
cal -m 4 -y 2025 -b 2 -a 1
```

Displays April 2025 with the two months before and one month after it.

### EXAMPLE 5

```PowerShell
cal -y 2025 -a 24
```

Shows 2025 through 2027

### EXAMPLE 6

```PowerShell
cal -DayOfYear -Three
```

Show the day number, starting from 1st January, for this month as well as last month and next month.

### EXAMPLE 7

```PowerShell
cal 2 2026 -three
```

Show February 2026 with the month prior and month after.

### EXAMPLE 8

```PowerShell
cal -Year 2025 -Highlight Cyan
```

Shows the specified year with a highlighted colour. Supports red, blue, green, yellow, orange, pink, cyan, magenta
and white. Disable all highlighting with - Highlight 'none'.

### EXAMPLE 9

```PowerShell
cal -culture ja-JP -Year 2025 -Highlight Orange
```

Display a calender using the  Japanese (Japan) culture for the specified year.

### EXAMPLE 10

```PowerShell
'Persian','Hijri','UmAlQura' | % { cal -calendar $_ -name }
```

Display three calendars (the current month) using the specified calendars with a banner to identify each
culture/calendar.

### EXAMPLE 11

```PowerShell
'en-au','en-us','dv','mzn' | % { ncal -c $_ -Name -Week -Highlight Yellow }
```

Display calendars for the specified cultures. This example illustrates the different DateTimeFormat information for
each culture (different start days for the week).

### EXAMPLE 12

```PowerShell
ncal -calendar Julian -m 1 -a 11
```

Shows this year in the Julian calendar.

Note: This actually works correctly, unlike the Linux ncal command (as at Feb 2025), which sometimes shows
the wrong month (shows this Julian month but in terms of month number on the Gregorian calendar),
depending on the day of the month.

### EXAMPLE 13

```PowerShell
ncal -cal Hijri -m 1 -a 11
```

Shows this year in the Hijri (Muslim) calendar.

Note: This is not supported with Linux ncal command.

## PARAMETERS

### -Month

Specifies the required month. This must be specified as a number 0..13. An 'f' (forward by one year) or a 'p'
(previous year) suffix can also be appended to the month number.

```yaml
Type: String
Parameter Sets: (All)
Aliases: m

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Year

Specifies the required year. If no month is specified, the whole year is shown.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Culture

Specifies the required culture. The system default culture is used by default.

```yaml
Type: String
Parameter Sets: UseCulture
Aliases: c, cul

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Calendar

Instead of a culture, specify a calendar. This allows displaying optional and other calendars not used by any
culture. They include Julian, Hijri, Hebrew and Chinese Lunar calendars.

```yaml
Type: String
Parameter Sets: UseCalendar
Aliases: cal

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FirstDayOfWeek

Display the specified first day of the week. By default, the required culture is used to determine this.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MonthPerRow

Display the specified number of months in each row. By default it is 3 months.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: r, row

Required: False
Position: 5
Default value: 3
Accept pipeline input: False
Accept wildcard characters: False
```

### -Highlight

By default, today's date is highlighted. Specify a colour to highlight today, the year/month headings and week
numbers or disable the default highlight with 'none'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Before

The specified number of months are added before the specified month(s). See -After for examples.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -After

The specified number of months are added after the specified month(s). This is in addition to any date range
selected by the -Year or -Three options. Negative numbers are allowed, in which case the specified number of months
is subtracted. For example ncal -after 11 simply shows the next 12 months in any culture.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Three

Display the current month together with the previous and following month. This is ignored if -Year is also
specified without a month.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DayOfYear

Display the day of the year (days one-based, numbered from 1st January).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Display the name of the specified culture and/or calendar name as a banner above the calendar.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction

{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [System.String]

### [System.Int]

## OUTPUTS

### [System.String]

## NOTES

Author: Roy Atkins

## RELATED LINKS

[https://github.com/atkinsroy/ncal/docs](https://github.com/atkinsroy/ncal/docs)
