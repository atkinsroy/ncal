# Calendar Utility

## ncal

This command displays calendar information similar to the Linux ncal command. It implements the same functionality,
including the ability to display multiple months, years, day of the year and month forward and month previous by
one year.

But in addition, the command can do a whole lot more:

1. Display a calendar in any supported culture. Month and day names are displayed in the appropriate language for
the specified culture and the appropriate calendar is used (e.g. Gregorian, Persian), along with appropriate
DateTimeFormat information (e.g. default first day of the week).
2. As well as display the primary calendar (used by each culture), also display optional calendars. These are
Hijri (Islamic or Muslim), Hebrew, Japanese (Solar), Korean (Solar) and Taiwanese (Solar) calendars. In addition,
the non-optional calendars are supported. These are calendars not used by any culture, but still observed for
religious, scientific or traditional purposes. Namely the Julian and Chinese, Japanese, Korean and Taiwanese
lunar calendars. (Note: Only the current era is supported).
3. Specify the first day of the week (Friday through Monday). The specified or current culture setting is used by
default. Friday through Monday are supported because all cultures use one of these days.
4. Display one to six months in a row, when multiple months are displayed (the default is 4).
5. Highlight the year and month headings, week numbers and todays date using a specified colour.

It is highly recommended that Windows Terminal is used with an appropriate font to ensure that ISO unicode
character sets are both available and are displayed correctly. With other consoles, like Visual Studio Code and the
default PowerShell console, some fonts might not display correctly and with extended unicode character sets,
calendars may appear misaligned.

**Note:** From version 1.22.10352.0 (Feb 2025) of Windows Terminal, grapheme clusters are now supported and are
turned on by default. A grapheme cluster is a single user-perceived character made up of multiple code points from
the Unicode Standard, introduced in .NET 5. Whilst this is considered the correct method for handling and
displaying Unicode character sets, PowerShell doesn't support grapheme clusters and thus, calandars in ncal appear
misaligned. This can be remedied, in the short term, by disabling grapheme cluster support in Settings >
Compatibility > Text measurement mode, selecting "Windows Console" and then restarting the Windows Terminal.

Use the following command to see the available cultures on your system and pass a culture name to ncal with the
-Culture parameter.

```PowerShell
Get-Culture -ListAvailable
```

## cal

Similar to the Linux cal command with similar functionality extras, as above. Displaying full day names and week
numbers are not supported with cal, but everything else works the same way.

## Get-Now

Display today's date in any of the calendars supported by .NET Framework. By default, today's date for every
supported calendar is shown. The Gregorian calendar is always shown, to compare with the specified calendar(s).

## Globalization

**ncal** and **cal** have been tested with over 800 cultures and work well providing that Windows Terminal is used
together with a font that supports unicode character sets. (I have been using the Lilex Nerd Font during the
development of ncal). In addition, calendars not primarily used by a culture are supported. These include the
Julian, Hijra (Islamic or Muslim calendar), Chinese lunar, Hebrew and several other calendars which are observed
in many parts of the world for religious or scientific purposes. Note that the Julian calendar uses an ISO 1806
culture because, well I live in a country that follows this standard. With the Asian lunar calendars, the 13th
month can be specified as the required month, but read later for problems supporting non-default calendars.

## Known Problems

1. All culture based calendars display well, except for cultures using the Chakma language (ccp, ccp-BD and
ccp-IN) which is misaligned because of varying lengths in the unicode characters. Log an issue if this affects you.
2. Some languages have really long month and day names. Rather than attempting to shorten these, they have been
left culturally correct. Again, if this is affecting you and you can help with the specifics, I'd be prepared to
look at this. For cultures that use extended unicode character sets, I will not attempt to shorten names. In mean
time, you can set -MonthInRow (or -r) to 1.
3. The non-default calendars have no DateTimeFormat properties of their own. So the culture that makes the most
sense is used. For some calendars, this is partially ok; for example the ar-SA (Saudi Arabia) culture uses the same
month names as the Hijri (Islamic or Muslim) calendar. But for other calendars, like Hebrew, they use different
month names from the closest culture (in this case, the he-IL (Israel) culture uses the Gregorian calendar and has
different month names in Hebrew to the Hebrew calendar). I suspect this is true for other calendars too. This also
affects week numbers and is especially noticeable with the Asian lunar calendars in years that have 13 months. The
Julian, Hijri and Hebrew calendars are also affected. In these cases, displaying week numbers is not supported.
The Asian solar calendars are ok.
4. Some lunar calendars have 13 months in some years. The thirteenth month displays ok when a year is specified,
but for the same reason as above, this month has no month name; the DateTimeFormat for the closest culture uses
Gregorian which has twelve months only. In these situations, the month name will be shown as '13'. In summary,
I don't think .NET Framework supports the none default calendars, with respect to DateTimeFormat, very well.
(Unless I am missing something).

## Usage

Here are some examples of ncal usage:

Example | Notes
:--- | :---
![Default ncal display](/Images/2025-02-01-01.png) | By default, the current month is shown with today highlighted. Use '-Highlight None' to remove this highlight.
![Month and year](/Images/2025-02-01-02.png) | The required month and year can be specified with or without -m and -y respectively. By default the local culture is used. Changing the culture affects the language (day and month names), the calendar used and the default first day of the month. The first day of the week can be changed from the cultural default using -FirstDayOfWeek (supports Friday through Monday).
![Specify a culture](/Images/2025-02-01-03.png) | Specify the required culture and use full length day names with -LongDayNames.
![Use f and p for forward and previous](/Images/2025-02-01-04.png) | Use 'f' or 'p' suffix after the required month to show forward and previous by 1 year, respectively.
![Specify -three](/Images/2025-02-01-05.png) |  Specify -three to display a target month with the month prior and month after. By default, this month is the target month, but this can be changed using -Month and -Year. -Three is ignored if a year with no month is specified.
![Specify -Year without month](/Images/2025-02-01-06.png) | Specifying a year without a month to show the entire year. Can be used with -Before and -After to show a number of months before and after the year being displayed. Use -Highlight to display month headings and today in another colour. Supported colours are red, yellow, blue, green, magenta, cyan, white, orange and pink. 'None' can also be specified to remove the default 'today' highlight.
![Specify -DayOfYear](/Images/2025-02-01-07.png) | Specify -DayOfYear to show days one-based, numbered from 1st January. This can be used with -month, -year, -three, -before and -after.
![Specify -MonthPerRow](/Images/2025-02-01-08.png) | By default, ncal shows up to 4 months in a row. This can be changed from 1 to 6. (For cal, the default months per row is 3.). This example shows -After and also -Week to show the week number of the year below. Highlighting affects the year/month heading, week numbers and todays date.
![UmAlQura](/Images/2025-02-01-09.png) | Example of showing this month (with 3 months following) in a different calendar. This example shows Saudi Arabian culture, which uses the UmAlQura calendar. Persian (e.g. fa, mzn) and ThaiBuddist (i.e th) calendars are also used by some cultures. Use Get-Culture -ListAvailable to see the cultures available on your system.
![Japanese](/Images/2025-02-11-01.png) | Example output from cal. Display a year in the Japanese culture (Gregorian calendar) with 4 months in a row and highlights in pink.
