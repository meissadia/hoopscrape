require_relative './test_helper'

class TestNbaTeamList < Minitest::Test
  include NbaUrls
  include PrintUtils
  # Validate Team List contents
  def setup
    @team_list = [
      ['BOS', 'Boston Celtics', 'Atlantic', 'Eastern'],
      ['BKN', 'Brooklyn Nets', 'Atlantic', 'Eastern'],
      ['NYK', 'New York Knicks', 'Atlantic', 'Eastern'],
      ['PHI', 'Philadelphia 76ers', 'Atlantic', 'Eastern'],
      ['TOR', 'Toronto Raptors', 'Atlantic', 'Eastern'],
      ['GSW', 'Golden State Warriors', 'Pacific', 'Western'],
      ['LAC', 'Los Angeles Clippers', 'Pacific', 'Western'],
      ['LAL', 'Los Angeles Lakers', 'Pacific', 'Western'],
      ['PHO', 'Phoenix Suns', 'Pacific', 'Western'],
      ['SAC', 'Sacramento Kings', 'Pacific', 'Western'],
      ['CHI', 'Chicago Bulls', 'Central', 'Eastern'],
      ['CLE', 'Cleveland Cavaliers', 'Central', 'Eastern'],
      ['DET', 'Detroit Pistons', 'Central', 'Eastern'],
      ['IND', 'Indiana Pacers', 'Central', 'Eastern'],
      ['MIL', 'Milwaukee Bucks', 'Central', 'Eastern'],
      ['DAL', 'Dallas Mavericks', 'Southwest', 'Western'],
      ['HOU', 'Houston Rockets', 'Southwest', 'Western'],
      ['MEM', 'Memphis Grizzlies', 'Southwest', 'Western'],
      ['NOP', 'New Orleans Pelicans', 'Southwest', 'Western'],
      ['SAS', 'San Antonio Spurs', 'Southwest', 'Western'],
      ['ATL', 'Atlanta Hawks', 'Southeast', 'Eastern'],
      ['CHA', 'Charlotte Hornets', 'Southeast', 'Eastern'],
      ['MIA', 'Miami Heat', 'Southeast', 'Eastern'],
      ['ORL', 'Orlando Magic', 'Southeast', 'Eastern'],
      ['WAS', 'Washington Wizards', 'Southeast', 'Eastern'],
      ['DEN', 'Denver Nuggets', 'Northwest', 'Western'],
      ['MIN', 'Minnesota Timberwolves', 'Northwest', 'Western'],
      ['OKC', 'Oklahoma City Thunder', 'Northwest', 'Western'],
      ['POR', 'Portland Trail Blazers', 'Northwest', 'Western'],
      ['UTA', 'Utah Jazz', 'Northwest', 'Western']
    ]
  end

  def test_live_data
    tl = NbaTeamList.new

    # Test Team Count
    assert_equal 30, tl.teamList[].size, 'NbaTeamList => Wrong # Teams'

    # Validate Header value
    assert_equal 'NBA Teams', tl.header, 'NbaTeamList => Wrong :header'

    tl.teamList[].each_with_index do |actual, idx|
      assert_equal @team_list[idx], actual, 'NbaTeamList => Content Fail'
    end
  end

  def test_file_data
    tl = NbaTeamList.new(file: 'test/data/teamList.html')
    tl.teamList[].each_with_index do |actual, idx|
      assert_equal @team_list[idx], actual, 'NbaTeamList => File Content Fail'
    end
  end

  def test_conversion
    tl = NbaTeamList.new(format: :to_structs,
                         file: 'test/data/teamList.html').teamList

    assert_equal 'BOS',       tl.first.team
    assert_equal 'Utah Jazz', tl.last.name
  end
end
