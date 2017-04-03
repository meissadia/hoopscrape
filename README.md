<img style='width:100%' src='./readme/logo-hoopscrape.png' />
hoopscrape is not associated with ESPN or the NBA   

[![Gem Version](https://badge.fury.io/rb/hoopscrape.svg)](https://badge.fury.io/rb/hoopscrape)
[![Code Climate](https://codeclimate.com/github/meissadia/hoopscrape/badges/gpa.svg)](https://codeclimate.com/github/meissadia/hoopscrape)
[![Build Status](https://travis-ci.org/meissadia/hoopscrape.svg?branch=master)](https://travis-ci.org/meissadia/hoopscrape)
[![Test Coverage](https://codeclimate.com/github/meissadia/hoopscrape/badges/coverage.svg)](https://codeclimate.com/github/meissadia/hoopscrape/coverage)

## Table of Contents
+ [Introduction](#introduction)
+ [Installation](#installation)
	+ [Rails](#rails)
	+ [Manual](#manual)
+ [Arrays, Hashes or Structs](#arrays-hashes-or-structs)
	+ [Working With Multiple Formats](#working-with-multiple-formats)
		+ [Default format](#default-format)
		+ [Same data using Hashes](#same-data-using-hashes)
		+ [Same data using Structs](#same-data-using-structs)
	+ [Customize Field Names for Hash and Struct Conversion](#customize-field-names-for-hash-and-struct-conversion)
		+ [Default As Template](#default-as-template)
		+ [Overwrite Default](#overwrite-default)
+ [Working with Navigators](#working-with-navigators)
	+ [Navigator Methods](#navigator-methods)
+ [Data Access](#data-access)
	+ [NBA Team List](#nba-team-list)
	+ [Boxscore](#boxscore)
		+ [Player Data](#player-data)
		+ [Team Data](#team-data)
	+ [Roster](#roster)
	+ [Player](#player)
	+ [Schedule](#schedule)
		+ [Past Schedule Games as Structs](#past-schedule-games-as-structs)
		+ [Future Schedule Games as Structs](#future-schedule-games-as-structs)
		+ [Select a specific Season Type](#select-a-specific-season-type)
		+ [Select Historic Schedule data](#select-historic-schedule-data)
+ [Chaining it all together](#chaining-it-all-together)
+ [Documentation](#documentation)
+ [Requirements](#requirements)
	+ [Ruby version](#ruby-version)
	+ [Dependencies](#dependencies)
+ [Testing](#testing)
+ [Contributing](#contributing)


## Introduction
The hoopscrape Ruby gem is a scraper for NBA data.
It provides a number of ways to simplify data interaction, including :
+ Structs - Intuitively access data via dot notation.
+ Hashes - Pass data directly to ActiveRecord CRUD methods for easy database interaction.
+ String arrays - Raw data for you to manipulate as you see fit.

Version 1.0.2
+ NbaBoxScore: fix error reading team names
+ gemspec: Update license identifier to GPL-3.0

+ Please report any [issues] you encounter!


## Installation
#### Rails
In your application&#39;s Gemfile, include :

```
gem 'hoopscrape'
```
In your project dir, execute :

```
$ bundle install
```
#### Manual
```
$ gem install hoopscrape
```
## Arrays, Hashes or Structs
If you intend to work with a single format, you can specify it at initialization. When working with multiple formats you should start with the default and convert as necessary using [Array#to_structs] or [Array#to_hashes].

```ruby
  require 'hoopscrape'
  hs   = HoopScrape.new                      # String Arrays
  hs_h = HoopScrape.new(format: :to_hashes)  # Hash Arrays
  hs_s = HoopScrape.new(format: :to_structs) # Struct Arrays
```
#### Working With Multiple Formats
Arrays can easily be converted to Hashes or Structs

##### Default format
```ruby
hs    = HoopScrape.new
bs    = es.boxscore(400828991)   # Return an NbaBoxscore object
stats = bs.homePlayers           # Returns a multidimensional array of Home Player stats
stats[4][2]                      # Player Name   # => 'R. Hood'
stats[4][20]                     # Player Points # => '30'
```
##### Same data using Hashes
```ruby
s_hashes = stats.to_hashes       # Returns array of Hashes
s_hashes[4][:name]               # Player Name   # => 'R. Hood'
s_hashes[4][:points]             # Player Points # => '30'
```
##### Same data using Structs
```ruby
s_structs = stats.to_structs     # Returns array of Structs
s_structs[4].name                # Player Name   # => 'R. Hood'
s_structs[4].points              # Player Points # => '30'
```
#### Customize Field Names for Hash and Struct Conversion
The [Array#to_hashes] and [Array#to_structs] methods can be passed an array of Symbols
to use in place of the default field names.

```ruby
team_list   = HoopScrape.teamList
team_list_s = t.to_structs([:abbrev, :long_team_name, :div, :conf]) # New Field Names
team_list_s.last.long_team_name    # => 'Utah Jazz'
```
Defaults are defined in the [SymbolDefaults] module.
You can overwrite them or use them as templates, replacing individual symbols using
the [Array#change_sym!] method.

##### Default As Template
`Safe method`

```ruby
my_names = S_ROSTER.dup.change_sym!(:p_name, :full_name).change_sym!(:salary, :crazy_money)
players  = HoopScrape.roster('CLE').players.to_structs(my_names)
players[3].full_name    # => 'LeBron James'
players[3].crazy_money  # => '22970500'
```
##### Overwrite Default
`Note: Changes affect all instances of hoopscrape`

```ruby
S_TEAM    # => [:team,  :name, :division, :conference]
S_TEAM.replace [:short, :long, :div, :conf]
t = HoopScrape.teamList.to_structs

t.first.short # => 'BOS'
t.first.long  # => 'Boston Celtics'
```
## Working with Navigators
Table data is wrapped in a [Navigator] class which provides helper methods for moving through the table. The type of object the Navigator returns matches the format provided at hoopscrape instantiation.

Note: Data converted using [Array#to_structs] or [Array#to_hashes] is not wrapped in a Navigator.

### Navigator Methods
```ruby
# <Navigator> A Navigator for Home Player Stats Table
navigator = HoopScrape.boxscore(400878158).homePlayers

navigator[]      # Array<Object> Returns the underlying Array of the Navigator
navigator[5]     # <Object> 6th row of data
navigator.size   # <Fixnum> Number of table rows
navigator.first  # <Object> Access the first data row
navigator.last   # <Object> Access the last data row
navigator.next   # <Object> Access the next data row     (nil if there is no more data)
navigator.curr   # <Object> Access the current data row  (nil at initialization)
navigator.prev   # <Object> Access the previous data row (nil if there is no more data)
```
## Data Access
### NBA Team List
```ruby
hs        = HoopScrape.new
team_list = es.teamList      # multidimensional array of Team info
team_list.last               # => ['UTA', 'Utah Jazz', 'Northwest', 'Western']
team_list.last[0]            # => 'UTA'
team_list.last[1]            # => 'Utah Jazz'
team_list.last[2]            # => 'Northwest'
team_list.last[3]            # => 'Western'
```
### Boxscore
Boxscore #homePlayers, #awayPlayers return a [Navigator]

```ruby
hs    = HoopScrape.new(format: :to_structs)
bs    = es.boxscore(400875892)   # Return an NbaBoxscore object

bs.id                 # <String> Boxscore ID    # => '400875892'
bs.gameDate           # <String> Game DateTime  # => '2016-05-07 00:00:00'

bs.homeName           # <String> Full Team Name
bs.homeScore          # <String> Team Score
bs.homeTotals         # <Object> Access the cumulative team totals
bs.homePlayers        # <Navigator> A Navigator for Home Player Stats Table

bs.awayName           # <String> Full Team Name
bs.awayScore          # <String> Team Score
bs.awayTotals         # <Object> Access the cumulative team totals
bs.awayPlayers        # <Navigator> A Navigator for Home Player Stats Table
```
##### Player Data
```ruby
wade = bs.homePlayers[4] # <Object> of data for Row 5

wade.team       # <String> Team ID          # => 'MIA'
wade.id         # <String> Player ID        # => '1987'
wade.name       # <String> Short Name       # => 'D. Wade'
wade.position   # <String> Position         # => 'SG'
wade.minutes    # <String> Minutes          # => '36'
wade.fgm        # <String> Shots Made       # => '13'
wade.fga        # <String> Shots Attempted  # => '25'
wade.tpm        # <String> 3P Made          # => '4'
wade.tpa        # <String> 3P Attempted     # => '6'
wade.ftm        # <String> Freethrows Made  # => '8'
wade.fta        # <String> Freethrows Att.  # => '8'
wade.oreb       # <String> Offensive Reb.   # => '1'
wade.dreb       # <String> Defensive Reb.   # => '7'
wade.rebounds   # <String> Total Rebounds   # => '8'
wade.assists    # <String> Assists          # => '4'
wade.steals     # <String> Steals           # => '0'
wade.blocks     # <String> Blocks           # => '0'
wade.tos        # <String> Turnovers        # => '4'
wade.fouls      # <String> Personal Fouls   # => '1'
wade.plusminus  # <String> Plus/Minus       # => '-8'
wade.points     # <String> Points           # => '38'
wade.starter    # <String> Starter?         # => 'true'
```
##### Team Data
```ruby
miami = bs.homeTotals   # <Object> Access the team totals
miami.team
miami.fgm
miami.fga
miami.tpm
miami.tpa
miami.ftm
miami.fta
miami.oreb
miami.dreb
miami.rebounds
miami.assists
miami.steals
miami.blocks
miami.turnovers
miami.fouls
miami.points
```
### Roster
Roster #players is a [Navigator].

```ruby
roster  = es.roster('UTA')
r_hash  = es.roster('UTA', format: :to_hashes)  # Pre-format players data
players = roster.players                        # Returns multidimensional array of Roster info
coach   = roster.coach                          # Coach Name # => 'Quinn Snyder'

# Roster as an array of objects
players = players.to_structs   # Returns array of Structs

players[2].team                # Team ID          # => 'UTA'
players[2].jersey              # Jersey Number    # => '11'
players[2].name                # Name             # => 'Alec Burks'
players[2].id                  # ID               # => '6429'
players[2].position            # Position         # => 'SG'
players[2].age                 # Age              # => '24'
players[2].height_ft           # Height (ft)      # => '6'
players[2].height_in           # Height (in)      # => '6'
players[2].salary              # Salary           # => '9463484'
players[2].weight              # Weight           # => '214'
players[2].college             # College          # => 'Colorado'
players[2].salary              # Salary           # => '9463484'
```
### Player
```ruby
player = es.player(2991473) # Returns an NbaPlayer object
player.name                 #=> "Anthony Bennett"
player.age                  #=> "23"
player.weight               #=> "245"
player.college              #=> "UNLV"
player.height_ft            #=> "6"
player.height_in            #=> "8"
```
### Schedule
Schedule #allGames, #pastGames, #futureGames return a [Navigator]

```ruby
schedule = es.schedule('UTA')                      # Gets latest available year and season type data
schedule = es.schedule('LAC', format: :to_structs) # Pre-format data (:to_hashes / :to_structs)
schedule = es.schedule('SAS', year: 2005)          # Gets historical data for season ending in 2005
schedule = es.schedule('POR', season: 1)           # Get specific season type (1 Pre/ 2 Regular/3 Post)

schedule.nextGame                            # <Object> Next unplayed game info
schedule.lastGame                            # <Object> Previously completed game info
schedule.nextTeamId                          # <String> Team ID of next opponent # => 'OKC'
schedule.nextGameId                          # <Fixnum> Index of next unplayed game

schedule.pastGames[]                         # Completed Games : [Object]
schedule.futureGames[]                       # Upcoming Games  : [Object]

past     = schedule.pastGames                # Completed Games : <Navigator>
future   = schedule.futureGames              # Upcoming Games  : <Navigator>
```
##### Past Schedule Games as Structs
```ruby
past = schedule.pastGames # Completed Games : <Navigator>
game = past.next          # <Object> Game info
game.team                 # Team ID
game.game_num             # Game # in Season
game.date                 # Game Date
game.home                 # Home?
game.opponent             # Opponent ID
game.win                  # Win?
game.team_score           # Team Score
game.opp_score            # Opponent Score
game.boxscore_id          # Boxscore ID
game.wins                 # Team Win Count
game.losses               # Team Loss Count
game.datetime             # Game DateTime
game.season_type          # Season Type
```
##### Future Schedule Games as Structs
```ruby
future = schedule.futureGames  # Upcoming Games  : <Navigator>
game   = future.next           # <Object> Game info
game.team                      # Team ID
game.game_num                  # Game # in Season
game.date                      # Game Date
game.home                      # Home?
game.opponent                  # Opponent ID
game.time                      # Game Time
game.win                       # Win?
game.tv                        # Game on TV?
game.opp_score                 # Opponent Score
game.datetime                  # Game DateTime
game.season_type               # Season Type
```
##### Select a specific Season Type
```ruby
preseason = es.schedule('BOS', season: 1)   # Get Preseason schedule
regular   = es.schedule('NYK', season: 2)   # Get Regular schedule
playoffs  = es.schedule('OKC', season: 3)   # Get Playoff schedule
```
##### Select Historic Schedule data
The year parameter should correspond to the year in which the season ended.

```ruby
schedule = es.schedule('SAS', year: 2005)    # Data for 2004-05 Season
```
## Chaining it all together
```ruby
# Get a Boxscore from a past game
HoopScrape.schedule('OKC', season: 2).allGames[42].boxscore(:to_structs).awayPlayers.first.name

# Get a Roster from a Team ID
HoopScrape.boxscore(400827977).homeTotals[0].roster(:to_hashes).players.first[:name]

'cle'.roster(:to_structs).players.next.position

# Get a Schedule from a Team ID
HoopScrape.teamList.last[0].schedule(:to_hashes).lastGame.boxscore

'gsw'.schedule(:to_structs).lastGame.boxscore
```
## Documentation
Available on [RubyDoc.info] or locally:

```
$ yard doc
$ yard server
```
## Requirements
### Ruby version

- Ruby &gt;= 1.9.3

### Dependencies

- Nokogiri ~> 1.6
- Rake
- minitest

## Testing
```
$ rake
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/meissadia/hoopscrape
<br>
<br>
<br>
&copy; 2016 Meissa Dia

[CHANGELOG]: ./CHANGELOG.md
[RubyDoc.info]: http://www.rubydoc.info/gems/hoopscrape/1.0.0
[Navigator]: http://www.rubydoc.info/gems/hoopscrape/1.0.0/Navigator
[Array#to_structs]: http://www.rubydoc.info/gems/hoopscrape/1.0.0/Array#to_structs-instance_method
[Array#to_hashes]: http://www.rubydoc.info/gems/hoopscrape/1.0.0/Array#to_hashes-instance_method
[Array#change_sym!]: http://www.rubydoc.info/gems/hoopscrape/1.0.0/Array#change_sym%21-instance_method
[SymbolDefaults]: ./lib/hoopscrape/SymbolDefaults.rb
[issues]: https://github.com/meissadia/hoopscrape/issues
