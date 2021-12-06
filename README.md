# ncal

This command displays calendar information similar to the Linux ncal command. It implements most of the main functionality, including the ability to display multiple months, years, week numbers and with today highlighted in various colours.

Here are some examples of ncal usage:

Example Month View | Notes
:--- | :---
![](/images/2021-12-06-095419.png) | By default, the current month is shown with today highlighted. Use '-Highlight None' to remove the default highlight.
![](/images/2021-12-06-095452.png) | The required month can be specified with a month number
![](/images/2021-12-06-095525.png) | or by specifying the locale specific month name
![](/images/2021-12-06-095624.png) | Specifying -month and -year together shows the required month from the required year
![](/images/2021-12-06-095829.png) | Specify the month number with an 'f' (for forward by one year) or 'p' (for previous by one year). These are mutually exclusive and are both ignored if a year is also specified

Example Year View | Notes
:--- | :---
![](/images/2021-12-06-095702.png) | Specifying a year without a month to show the entire year. This will override a month with 'f' and 'p' specified. Use -Highlight to display month headings and today in another colour. Supported colours are red, yellow, blue, green, magenta, cyan and white. 'None' can also be specified to remove the default highlight.
![](/images/2021-12-06-095735.png) | Display Julian Days (days one-based, numbered from 1st January)
![](/images/2021-12-06-095927.png) | With either month or year view, additional months can be added in front of and behind the specified month(s) with -Before and -After respectively. Show week numbers (beneath each week column) using -Week.
![](/images/2021-12-06-100948.png) | Example displaying a calendar in Urdu. 813 locales have been tested, with localised month names and day abbreviations being used. 
![](/images/2021-12-06-101044.png) | Example displaying a calendar in Russian
