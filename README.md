# ncal / cal

This PowerShell script displays calendar information similar to the Linux **ncal** and **cal** commands. It implements most of the main functionality, including the ability to display multiple months, years, Julian days, week numbers and with today highlighted in various colours.

Note: PowerShell V7.2.0 (using $PSStyle) is required to show highlighting. It will work with previous versions, but -Highlight doesn't do anything. This could be fixed to support old versions, but onwards and upwards.

I have added the Linux **cal** command now also. It supports highlighting, Year, Month, Before and After, Three and JulianDay parameters, as well as display Monday as first day of the month. So pretty much everything **ncal** can do, except for month numbers.

I have added -FullDayName to **ncal** and -MonthPerRow in both commands. By default, **ncal** displays 4 months per row, **cal** displays 3 months per row.

## Globalization

**ncal** and **cal** have been tested with all 813 locales and they work well with most of them. For languages with double width character sets (like Kanji and other Asian character sets), both utilities display correctly aligned calendars. However, right-to-left (RTL) languages (like Arabic, Hebrew, Pasto and Urdu) do not appear to have particularly good support in Windows. For example, in the VS code terminal, characters are aligned correctly, but are shown in reverse and are left justified. In Windows terminal, RTL characters are correctly shown right-to-left but alignment is pretty buggy. I suspect this is a terminal rendering issue rather than .NET support. For example, month headings can be correctly centred, but when they are concatenated together and displayed in Windows Terminal, month names "bleed" into the white space of an adjacent month. Alignment issues are particularly unpredictable when mixing RTL language character sets with latin characters (e.g. month name in Urdu together with year in latin numbers). For this reason, the best results I have found with RTL languages is to show just the month. I will potentially revisit this, if RLT language support improves.

Persian, some Arabic and other Middle Eastern locales use the Persian Calendar (also referred to as the Iranian Calendar). This is a solar Hijri calendar and starts from the year of the Hijri, which corresponds to 622 C.E. This is different to the Hijri Calendar (also referred to as the Muslim or Islamic Calendar), which is a lunar based calendar and is used to determine the proper days on which to celebrate Islamic holy days. The Hijri Calendar is available in .NET as an optional calender for these locales but has not been implemented in **ncal** or **cal**. Note that the Hijri Calendar is used by default (with a few minor differences) in Saudi Arabia and so is implemented for this locale (ar-SA).

## Usage

Here are some examples of ncal usage:

Example | Notes
:--- | :---
![](/images/2021-12-06-095419.png) | By default, the current month is shown with today highlighted. Use '-Highlight None' to remove the default highlight.
![](/images/2021-12-06-095452.png) | The required month can be specified with a month number
![](/images/2021-12-06-095525.png) | or by specifying the locale specific month name
![](/images/2021-12-06-095624.png) | Specifying -month and -year together shows the required month from the required year
![](/images/2021-12-06-095829.png) | Specify the month number with an 'f' (for forward by one year) or 'p' (for previous by one year). These are mutually exclusive and override year if also specified
![](/images/2021-12-06-112934.png) | Specify -Three to display a target month with the month prior and month after. By default, this month is the target month, but this can be changed using -Month and -Year. -Three is ignored if just -Year is specified.
![](/images/2021-12-06-095702.png) | Specifying a year without a month to show the entire year. Ignored if month with 'f' or 'p' is also specified. Use -Highlight to display month headings and today in another colour. Supported colours are red, yellow, blue, green, magenta, cyan, white and orange. 'None' can also be specified to remove the default highlight.
![](/images/2021-12-06-095735.png) | Display Julian Days (days one-based, numbered from 1st January). This can be used with -month, -year, -three, -before and -after.
![](/images/2021-12-06-095927.png) | With either month or year view, additional months can be added in front of and behind the specified month(s) with -Before and -After respectively. This works with -Month, -Year and -Three. Show week numbers (beneath each week column) using -Week.
![](/images/2021-12-06-100948.png) | Example displaying a calendar in Urdu. 813 locales have been tested, with localised month names and day abbreviations being used.
![](/images/2021-12-06-101044.png) | Example displaying a calendar in Russian
