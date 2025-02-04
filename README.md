# Calendar Utility

## ncal

This command displays calendar information similar to the Linux ncal command. It implements the same functionality,
including the ability to display multiple months, years, week number per year, day of the year and month forward
and previous by one year.

But in addition, the command can do a whole lot more:

1. Display a calendar in any supported culture. Month and day names are displayed in the appropriate language for
the specified culture and the appropriate calendar is used (e.g. Gregorian, Persian).
2. Not only display the primary calendar (used by each culture), but also display optional calendars. These are
Hijri, Hebrew, Japanese (Solar), Korean (Solar) and Taiwanese (Solar) calendars. In addition, the non-optional
calendars (i.e. calendars not used by any culture, but still observed for religious, scientific or traditional
purposes). These are the Julian and Chinese, Japanese, Korean and Taiwanese Lunar calendars. (Note: Only the
current era is supported).
3. Specify the first day of the week (Friday through Monday). The specified or current culture setting is used by
default. Friday through Monday are supported because all cultures use one of these days.
4. Display abbreviated (default) or full day names, specific to the culture.
5. Display one to six months in a row, when multiple months are displayed (the default is 4).
6. When displaying week numbers, they will align correctly with respect to the default or specified first day of
the week.
7. Highlight the year and month headings, todays date and week numbers using a specified colour.

It is highly recommended that Windows Terminal is used with an appropriate font to ensure that ISO unicode
character sets are both available and are displayed correctly. With other consoles, like Visual Studio Code, the
ISE and the default PowerShell console, some fonts might not display correctly and with extended unicode character
sets, calendars may appear misaligned.

Use the following command to see the available cultures on your system and pass a culture name to ncal with the
-Culture parameter.

```PowerShell
Get-Culture -ListAvailable
```

## cal

Similar to the Linux cal command with similar functionality extras, as above. Displaying full day names and week
numbers are not supported with cal, but everything else works the same.

## Globalization

**ncal** and **cal** have been tested with over 800 cultures and work well providing that Windows Terminal is used
together with a font that supports unicode character sets.  Currently, 'Optional' calendars (in .Net) are not
supported. These include the Julian, Hijra (Islamic), Chinese Lunar, Hebrew and several other calendars which are
not used primarily by any culture but are observed in many parts of the world for religious or scientific purposes.

## Known Problems

1. All calendars display well, except for cultures using the Chakma language (ccp, ccp-BD and ccp-IN). Log an
issue if this affects you.
2. Some languages have really long month and day names. Rather than attempting to shorten these, they have been
left culturally correct. Again, if this is affecting you and you can help with the specifics, I'd be prepared to
look at this. For cultures that use extended unicode character sets, I probably will not attempt to shorten names.
3. The non-optional calendars have no DateTimeFormat properties. So the culture that makes the most sense is used.
For some calendars, this is ok; the month and day names from the ar-SA (Saudi Arabia) uses the same names. But
other calendars, like Hebrew, use different names to the closest culture (in this case he-IL, this uses the
Gregorian calendar and has different names in Hebrew to the Hebrew calendar). I suspect this is true for other
calendars too. Note that the Julian calendar uses an ISO 1806 culture because, well I live in a country which
follows this standard.
4. Some Lunar calendars have 13 months in some years. The thirteenth month displays ok when displaying a year, but
for the same reason as above, this month has no heading. This is because the DateTimeFormat for the closest culture
invariably uses Gregorian which has twelve months only. In summary, I don't think .NET Framework supports none
default calendars with respect to DateTimeFormat.

## Usage

Here are some examples of ncal usage:

Example | Notes
:--- | :---
![Default ncal display](/Images/2025-02-01-01.png) | By default, the current month is shown with today highlighted. Use '-Highlight None' to remove this highlight.
![Month and year](/Images/2025-02-01-02.png) | The required month and year can be specified with or without -m and -y respectively. Culture is the third parameter. By default the local culture is used. Changing the culture affects the language (day and month names), the calendar used and the default first day of the month. The Americas, India, Japan and some Arabic, African and East Asian countries uses Sunday. Countries that adopt the Persian calendar (e.g. Iran, Afghanistan, Somalia and other Islamic countires) start their week on Saturday. All other countries (including Western and Eastern Europe, Russia, Asia Pacific and most of Asia) follow ISO 8601, with the week starting on Monday. According to .Net, one country, the Maldives, uses Friday. The first day of the week can be changed from the cultural default using -FirstDayOfWeek (supports Friday through Monday).
![Specify a culture](/Images/2025-02-01-03.png) | Specify the required culture and use full length day names with -LongDayNames.
![Use f and p for forward and previous](/Images/2025-02-01-04.png) | Use 'f' or 'p' suffix after the required month to show forward and previous by 1 year, respectively.
![Specify -Three](/Images/2025-02-01-05.png) |  Specify -Three to display a target month with the month prior and month after. By default, this month is the target month, but this can be changed using -Month and -Year. -Three takes priority over -Year (i.e. with the number of months to display).
![Specify -Year without month](/Images/2025-02-01-06.png) | Specifying a year without a month to show the entire year. Ignored if -Month or -Three is also specified. Can be used with -Before and -After to show a number of months before and after the year being displayed. Use -Highlight to display month headings and today in another colour. Supported colours are red, yellow, blue, green, magenta, cyan, white and orange. 'None' can also be specified to remove the default 'today' highlight.
![Specify -DayOfYear](/Images/2025-02-01-07.png) | Specify -DayOfYear to show days one-based, numbered from 1st January. This can be used with -month, -year, -three, -before and -after.
![Specify -MonthPerRow](/Images/2025-02-01-08.png) | By default, ncal shows up to 4 months in a row. This can be changed from 1 to 6. (For cal, the default months per row is 3.). This example shows -After and also -Week to show the week number of the year below. Highlighting affects the year/month heading, week numbers and todays date.
![UmAlQura](/Images/2025-02-01-09.png) | Example of showing this month (with 3 months following) in a different calendar. This example shows Saudi Arabian culture, which uses the UmAlQura calendar. Persian (e.g. fa, mzn) and ThaiBuddist (i.e th) calendars are also used by some cultures. Use Get-Culture -ListAvailable to see the cultures available on your system.
