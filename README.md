# ncal

This Powershell command displays calendar information similar to the Linux **ncal** command. It implements most of the main functionality, including the ability to display multiple months, years, week numbers and with today highlighted in various colours.

Note: **ncal** requires PowerShell V7.2.0 (using $PSStyle) to show highlighting. It will work with previous versions, but -Highlight doesn't do anything. This could be fixed to support old versions, but onwards and upwards.

I have added the Linux **cal** command now also. It supports highlighting, year, month, before and after, three and juliandate parameters, as well as display Monday as first day of the month. So pretty much everything **ncal** can do, except month numbers. This is actually more than the Linux **cal** command can do - e.g. no highlighting.

I have tested **ncal** and **cal** with all 813 locales and it works well with most. With some languages, there might be alignment issues with day of the week when there are long names. This mainly affects some Islamic and Asian locales.

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

### NOTE: 
I think Windows displays the wrong information with Muslim/Islamic calendars (Hijri calendar). Year 1 "Anno Hegirae" (meaning "in the year of the Hijrah") is 622 CE in Gregorian calendar, so 2022 appears as 1401 in Windows. However, I think this is incorrect. It might be consistant with 12 solar months, but I think the discrepancy is due to the Hijri calendar observing lunar months, consisting of 354 or 355 days per year. The current Islamic year is 1444 AH - which runs from approximately 30 July 2022 to 18 July 2023 according to Wikipedia. Consequently, I'm pretty sure that both the year, month and day of the week for the currect day are displayed incorrectly.
