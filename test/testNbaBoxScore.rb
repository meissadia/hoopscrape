require_relative './test_helper'

class TestNbaBoxScore < Minitest::Test
  include NbaUrls
  attr_reader :game_id

  # Stat patterns
  @@p_team_id = /^[A-Z]{3}$/
  @@p_num      = /^\d*$/
  @@p_pminus   = /^[+-]?\d+$/
  @@p_bool     = /^true|false$/
  @@p_tname    = /\w+\s\w+(\sw+)?/
  @@p_pos      = /(^(C|F|G|SF|SG|PF|PG)(\/(C|F|G|SF|SG|PF|PG)))$|(^(C|F|G|SF|SG|PF|PG)$)/
  @@p_short_name = /(^[A-Z]\.\s[A-Z][a-z]*|(^[A-Z][a-z]+))/

  # => Test Game: Past
  def test_live_past
    bs = NbaBoxScore.new(game_id: 400828035)
    assert_equal false, bs.nil?, 'Unable to Initialize object'
    assert_equal '2015-11-15 00:00:00', bs.gameDate, 'Game Date => Incorrect'

    # Validate Team Names
    assert_match @@p_tname, bs.awayName, 'Away Team Name => Incorrect'
    assert_match @@p_tname, bs.homeName, 'Home Team Name => Incorrect'

    # Validate Box Score Stat line
    # Sample Line: ['UTA', '4257', 'D. Favors', 'PF', '32', '11', '20', '0', '1', '1', '1', '4', '5', '9', '3', '0', '2', '4', '2', '+1', '23', 'true']
    assert @@p_team_id =~ bs.awayPlayers[0][0], "Invalid Team ID: #{bs.awayPlayers[0][0]}"
    assert @@p_team_id =~ bs.homePlayers[0][0], "Invalid Team ID: #{bs.homePlayers[0][0]}"
    assert @@p_pos     =~ bs.homePlayers[0][3], "Invalid Position: #{bs.homePlayers[0][3]}"
    assert @@p_pos     =~ bs.awayPlayers[0][3], "Invalid Position: #{bs.awayPlayers[0][3]}"
    assert_equal 16, bs.awayTotals.size, "Away Totals => Wrong # columns\n#{bs.awayTotals.inspect}"
    assert_equal 16, bs.homeTotals.size, 'Home Totals => Wrong # columns'

    digits = [1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20] # numeric columns
    digits.each do |idx|
      assert @@p_num =~ bs.awayPlayers[0][idx].to_s, "awayPlayers[#{idx}] not a number"
      assert @@p_num =~ bs.homePlayers[0][idx].to_s, "homePlayers[#{idx}] not a number"
    end

    bool = [bs.awayPlayers[0][21], bs.homePlayers[0][21]] # boolean columns
    bool.each do |value|
      assert @@p_bool =~ value, "Invalid boolean string: #{value}"
    end

    pminus = [bs.homePlayers[0][19], bs.awayPlayers[0][19]] # plus/minus columns
    pminus.each do |value|
      assert @@p_pminus =~ value, "Not a plus/minus stat: #{value}"
    end
  end

  # =>  Boxscore with Non-NBA Team
  def test_live_non_nba_opponent
    bs = NbaBoxScore.new(game_id: 400832210)
    assert_equal 'Milan Olimpia', bs.homeName
    assert_equal '2015-10-06 00:00:00', bs.gameDate, 'Game Date -> Incorrect'
  end

  def test_live_structs_navigator
    bs = NbaBoxScore.new(game_id: 400828035, format: :to_structs)
    assert @@p_short_name =~  bs.awayPlayers.first.name, 'Invalid Name'
    assert @@p_short_name =~  bs.awayPlayers.next.name,  'Invalid Name'
    assert @@p_short_name =~  bs.homePlayers.first.name, 'Invalid Name'
    assert @@p_short_name =~  bs.homePlayers.next.name,  'Invalid Name'
    assert @@p_pos =~         bs.awayPlayers.first.position, 'Invalid Position'
    assert @@p_pos =~         bs.homePlayers.first.position, 'Invalid Position'
    assert @@p_num =~         bs.awayTotals.rebounds, 'Invalid Number'
    assert @@p_num =~         bs.awayScore,           'Invalid Number'
    assert @@p_num =~         bs.homeTotals.fta,      'Invalid Number'
    assert @@p_num =~         bs.homeScore,           'Invalid Number'

    # Validate Team Names
    assert_match @@p_tname, bs.awayName, 'Away Team Name => Incorrect'
    assert_match @@p_tname, bs.homeName, 'Home Team Name => Incorrect'
  end
end
