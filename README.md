# ncal

This Powershell command displays calendar information similar to the Linux **ncal** command. It implements most of the main functionality, including the ability to display multiple months, years, week numbers and with today highlighted in various colours.

Note: **ncal** requires PowerShell V7.2.0 (using $PSStyle) to show highlighting. It will work with previous versions, but -Highlight doesn't do anything. This could be fixed to support old versions, but onwards and upwards.

I have added the Linux **cal** command now also. It supports highlighting, year, month, before and after, three and juliandate parameters, as well as display Monday as first day of the month. So pretty much everything **ncal** can do, except month numbers. This is actually more than the Linux **cal** command can do - e.g. no highlighting.

I have added -FullDayName to **ncal** and -MonthPerRow in both commands. By default, **ncal** displays 4 months per row, **cal** displays 3 months per row.

## Globalization

**ncal** and **cal** have been tested with all 813 locales and it works well with most. With some languages, there might be alignment issues with day of the week due to longer abbreviated day names or for some locales using extended character sets. 

### Note:
Persian locales, fa, fa-AF (Afghanistan) and fa-IR (Iran), all use the Persian Calendar. This is a solar Hijri calendar and starts from the year of the Hijri, which corrosponds to 622 C.E. This is different to the Hijri Calendar, which is a solar based calendar and is used typically for religious purposes. The Hijri Calendar is available in .NET as an optional calender for these locales but has not been implemented in **ncal** or **cal**.  

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
