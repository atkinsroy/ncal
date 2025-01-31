# Calendar Utility

## ncal

This command displays calendar information similar to the Linux ncal command. It implements most of the same functionality, including the ability to display multiple months, years, week numbers, day of the year and specified month forward and previous by one year.

But in addition, the command can do a whole lot more:

1. Display a calendar in any supported culture. Month and day names are displayed in the chosen culture as well as using the correct primary calendar for each culture. Use the following command:

```PowerShell
Get-Culture -ListAvailable
```

to see the available cultures and pass the culture name to ncal with the -Culture parameter.

2. Start of week can be selected (Friday through Monday). By default, the culture setting is used.
3. Display abbreviated (default) or full day names, specific to the culture.
4. Display one to six months in a row, when multiple months are displayed (the default is 4).
5. When display week numbers, they will align correctly with the first day of the week.
6. Highlight month headings, today and week numbers with a specified colour.

It is highly recommended that Windows Terminal is used with an appropriate font to ensure that ISO unicode character sets are both available and display properly. With one or two exceptions, all cultures align correctly. Results for cultures using unicode character sets probably wont look that great using other terminals.

## cal

Similar to the Linux cal command with similar functionality extras, as above. Displaying full day names and week numbers are not supported with cal, but everything else works the same.

## Globalization

**ncal** and **cal** have been tested with over 800 cultures and work well providing that Windows Terminal is used together with a font that supports unicode character sets.  Currently, 'Optional' calendars (in .Net) are not supported. These include the Julian, Hijra (Islamic), Chinese Lunar, Hebrew and several other calendars which are not used primarily by any culture but are observed in many parts of the world for religious or scientific purposes.

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
