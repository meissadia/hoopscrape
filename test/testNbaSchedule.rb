require_relative './test_helper'

class TestNbaSchedule < Minitest::Test
  include NbaUrls
  include PrintUtils

  # Test Regular Season
  def test_file_regular
    schedule = NbaSchedule.new(file: 'test/data/scheduleData.html', season_type: 2) # Data 11/21/15

    # Test allGames
    assert_equal 82, schedule.allGames.size, 'NbaSchedule: Wrong Season Length'

    # Test nextGame
    expected = 12
    assert_equal expected, schedule.nextGameId

    expected = ['UTA', '13', 'Nov 23', 'true', 'OKC', '9:00 PM ET', 'false', '2015-11-23 21:00:00', '2']
    assert_equal expected, schedule.nextGame

    # Test lastGame
    expected = ['UTA', '12', 'Nov 20', 'false', 'DAL', 'false', '93', '102', '400828071', '6', '6', '2015-11-20 00:00:00', '2']
    assert_equal expected, schedule.lastGame

    # Test futureGames
    expected = 70
    assert_equal expected, schedule.futureGames.size

    # Test pastGames
    expected = 12
    assert_equal expected, schedule.pastGames.size

    asTable(schedule.pastGames[], 15, 'UTA Past', true)

    # Test getNextTeam
    expected = 'OKC'
    assert_equal expected, schedule.nextTeamId
  end

  # Test Preseason
  def test_file_preseason
    schedule = NbaSchedule.new(team_id: 'GSW',
                               file: 'test/data/schedulePreseasonData.html',
                               season_type: 1)
    assert_equal 7, schedule.allGames.size
    assert_equal 7, schedule.pastGames.size
    assert_equal 0, schedule.futureGames.size
    assert_equal 4, schedule.losses
    assert_equal 3, schedule.wins

    # Test Schedule with Non-NBA Teams
    schedule = NbaSchedule.new(team_id: 'BOS',
                               file: 'test/data/scheduleInternationalData.html')
    assert_equal 7, schedule.allGames.size
    assert_equal 7, schedule.pastGames.size
    assert_equal 0, schedule.futureGames.size
  end

  # Test Playoffs
  def test_file_playoff
    schedule = NbaSchedule.new(team_id: 'GSW',
                               file: 'test/data/schedulePlayoffData.html',
                               season_type: 3)
    assert_equal 'CLE', schedule.nextTeamId
    assert_equal 7,     schedule.futureGames.size
    assert_equal 24,    schedule.allGames.size
    assert_equal '3',   schedule.nextGame.last
    assert_equal 12,    schedule.wins
    assert_equal 5,     schedule.losses
  end

  def test_structs
    schedule = NbaSchedule.new(file: 'test/data/scheduleData.html',
                               season_type: 2,
                               format: :to_structs) # Data 11/21/15

    assert_equal '1',   schedule.allGames.next.game_num
    assert_equal '2',   schedule.allGames.next.game_num
    assert_equal '2',   schedule.allGames.next.wins
    assert_equal 'OKC', schedule.nextGame.opponent
  end

  def test_historic_data
    s = HoopScrape.schedule 'UTA', format: :to_structs, year: 2005
    assert_equal '2004-05', s.year
    assert_equal 'LAL',     s.allGames.first.opponent
  end

  def test_historic_schedule
    s = HoopScrape.schedule 'UTA', format: :to_structs, year: 2016

    assert_equal '400829115', s.lastGame.boxscore_id
  end
end
