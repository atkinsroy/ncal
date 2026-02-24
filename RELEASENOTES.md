# Release Notes

## [4.0.0] - 2026-02-24

### Added

- Zodiac animals for all Asian Lunar calendars. Multiple full years are supported. Partial years are ignored.
- Zodiac animals show translation in the appropriate language.

### Changed

- Major refactoring to reduce duplication in codebase, separation of logic into more helper functions and overall quality improvements.

### Fixed

- Asian Lunar calendars have leap months, formally shown as "13". These months are correctly shown as "leap month" in the appropriate language for a given culture/calendar.
- When -Year is specified, years are now aligned so that year headings are properly aligned. This is appropriate when multiple years are shown using -Before and -After with -Year.
- ISO 1801 week numbers are correctly shown, according to .NET method being used. This means that the last week of the year may partially or wholly appear as week 53. Some discrepancies may still be noticed when using -FirstDayOfWeek to alter this from the default for a given culture.
- -After and -Before now correctly *remove* months if a negative number is specified, like Linux ncal/cal.
- Other minor bug fixes.

---

## [3.1.X] - 2025-01-5

### Added

- Initial project setup.
- Base documentation structure.

### Changed

- First iteration of Zodiac Animal for Chinese Lunar calendars added in 3.1.8.

### Fixed

- N/A
