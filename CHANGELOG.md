### Change Log :: HoopScrape

## Version 1.1
+ Fixed security vulnerabilities with Nokogiri and Rubocop.  Unfortunately, this means HoopScrape now requires Ruby >= 2.1.0
+ Updated test suite.

## Version 1.0.5
+ NbaPlayer: Add player id to return structure
+ Documentation cleanup

## Version 1.0.4
+ NbaBoxScore: Update failed tests to utilize pattern matching.

## Version 1.0.3
+ NbaSchedule: fix error in extract_boxscore_id when reading Playoff schedules

## Version 1.0.2
+ NbaBoxScore: fix error reading team names
+ gemspec: Update license identifier to GPL-3.0

## Version 1.0.1.1
+ TestSuite: Replace hardcoded player info in testNbaPlayer with pattern matching

## Version 1.0.1
+ Bugfix: Double names (i.e. K. GarnettK. Garnett) in NbaBoxScore

## Version 1.0.0
- Initial release under new name
