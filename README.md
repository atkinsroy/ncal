# Calendar Utility

## ncal

This command displays calendar information similar to the Linux ncal command. It implements most of the same functionality, including the ability to display multiple months, years, week numbers, day of the year and specified month forward and previous by one year.

But in addition, the command can do a whole lot more:

1. Display a calendar in any supported culture. Month and day names are displayed in the chosen culture as well as using the correct primary calendar for each culture.
2. Start of week can be selected (Friday through Monday). By default, the culture setting is used.
3. Display abbreviated (default) or full day names, specific to the culture.
4. Display one to six months in a row, when multiple months are displayed (the default is 4).
5. When display week numbers, they will align correctly with the first day of the week.
6. Highlight month headings, today and week numbers with a specified colour.

It is highly recommended that Windows Terminal is used with an appropriate font to ensure that ISO unicode character sets are both available and display properly. With one or two exceptions, all cultures align correctly. Results for cultures using unicode character sets probably wont look that great using other terminals.

Use the following command to see the available cultures on your system and pass a culture name to ncal with the -Culture parameter

```PowerShell
Get-Culture -ListAvailable
```

## cal

Similar to the Linux cal command with similar functionality extras, as above. Displaying full day names and week numbers are not supported with cal, but everything else works the same.

## Globalization

**ncal** and **cal** have been tested with over 800 cultures and work well providing that Windows Terminal is used together with a font that supports unicode character sets.  Currently, 'Optional' calendars (in .Net) are not supported. These include the Julian, Hijra (Islamic), Chinese Lunar, Hebrew and several other calendars which are not used primarily by any culture but are observed in many parts of the world for religious or scientific purposes.

## Usage

Here are some examples of ncal usage:

Example | Notes
:--- | :---
![Default ncal display](/images/2025-02-01 14 53 51.png) | By default, the current month is shown with today highlighted. Use '-Highlight None' to remove this highlight.
![Month and year](/images/2025-02-01 14 54 50.png) | The required month and year can be specified with or without -m and -y respectively. Culture is the third parameter. By default the local culture is used. Changing the culture affects the default first day of the month (the Americas, India, Japan and some Arabic, African and East Asian countries uses Sunday). Countries that adopt the Persian calendar (e.g. Iran, Afghanistan and Somalia) start their week on Saturday. All other countries (including Western and Eastern Europe, Russia, Asia Pacific and most of Asia) follow ISO 8601, with the week starting on Monday. According to .Net, one country, the Maldives, uses Friday. The first day of the week can be changed from the cultural default using -FirstDayOfWeek (supports Friday through Monday).
![Specify a culture](/images/2025-02-01 14 55 46.png) | Specify the required culture and use full length day names.
![Use f and p for forward and previous](/images/2025-02-01 14 57 45.png) | Use 'f' or 'p' suffix after the required month to show forward and previous by 1 year, respectively.
![Specify -Three](/images/2025-02-01 14 58 44.png) |  Specify -Three to display a target month with the month prior and month after. By default, this month is the target month, but this can be changed using -Month and -Year. -Three is ignored if just -Year is specified.
![Specify -Year without month](2025-02-01 14 59 59.png) | Specifying a year without a month to show the entire year. Ignored if month with 'f' or 'p' is also specified. Can be used with -Before and -After to show a number of months before and after the year being displayed. Use -Highlight to display month headings and today in another colour. Supported colours are red, yellow, blue, green, magenta, cyan, white and orange. 'None' can also be specified to remove the default highlight.
![Specify -DayOfYear](/images/2025-02-01 15 00 50.png) | Specify -DayOfYear to show days one-based, numbered from 1st January. This can be used with -month, -year, -three, -before and -after.
![Specify -MonthPerRow](/images/2025-02-01 15 03 34.png) | By default, ncal shows up to 4 months in a row. This can be changed rom 1 to 6. (For cal, the default months per row is 3.). This example shows -After and also -Week to show the week number of the year below. Highlighting affects the year/month heading, week numbers and todays date.
![UmAlQura](/images/2025-02-01 15 04 42.png) | Example of showing this month (with 3 months following) in a different calendar. This example shows Saudi Arabian culture, which uses the UmAlQura calendar. Persian (e.g. fa, mzn) and ThaiBuddist (i.e th) calendars are also used by some cultures. Use Get-Culture -ListAvailable to see the cultures available on your system.
