# Release Notes

## [4.0.X] - 2026-02-24

### Added

- Show Zodiac animals for all Asian Lunar calendars. This now works across multiple full years too. Partial years are ignored.
- Zodiac animals show translation in the appropriate language.

### Changed

- Refactored to reduce duplication in codebase, especially between Get-Ncalendar and Get-Calendar. Separation of logic into more helper functions and overall quality improvements. There should not be any breaking changes, but updates are substantial enough to warrent a major version update.

### Fixed

- Asian Lunar calendars have leap months, formally shown as "13". These months are now correctly shown as "leap month" in the appropriate language for a given culture/calendar.
- When -Year is specified, years are now aligned so that year headings also properly aligned. This is appropriate when multiple years are shown using -Before and -After with -Year.
- ISO 8601 week numbers are correctly shown, according to .NET method being used. This means that the last week of the year may partially or wholly appear as week 53. Some discrepancies may still be noticed when using -FirstDayOfWeek to alter this from the default for a given culture. Note that Linux ncal/cal *do not* show correct ISO 8601 week numbers, according to several sources (e.g.  <https://www.epochconverter.com/Weeks/2026>).
- The -After and -Before parameters now correctly *remove* months if a negative number is specified, like Linux ncal/cal.
- Other minor bug fixes.

---

## [3.1.X] - 2025-02-10

### Added

- Added support for Calendar parameter. This supports the already supported primary calendars (Gregorian, Persian, etc.) but also optional calendars like Hiriji and the Chinsese Lunar calendar.

### Changed

- First iteration of Zodiac Animal for Chinese Lunar calendar added in 3.1.8.

### Fixed

- Minor bug fixes.

---

## [3.0.X] - 2025-02-1

### Added

- Initial project setup.
- ncal, cal and Get-Now. Support for month, year, culture, before, after, three, highlight, week, day of the week and long day name parameters.
- Base documentation structure.

### Changed

- N/A

### Fixed

- N/A
