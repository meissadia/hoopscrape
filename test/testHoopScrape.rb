require_relative './test_helper'

class TestHoopScrape < Minitest::Test
  def test_integration
    hs    = HoopScrape.new
    bs    = hs.boxscore(400828991)
    stats = bs.homePlayers # Returns multidimensional array of Home Player stats
    # binding.pry
    # Convert String array to Hash array
    stat_hashes = stats[].to_hashes # Returns array of Hashes
    assert_equal 'D. Favors', stat_hashes.first[:name],   'Boxscore.Name'
    assert_equal '14',        stat_hashes.first[:points], 'Boxscore.Points'

    # Convert String array to Struct array
    symbols      = S_BOX_P
    stat_structs = stats[].to_structs(symbols) # Returns array of Structs
    assert_equal 'D. Favors', stat_structs.first[:name],   'Boxscore.Name'
    assert_equal '14',        stat_structs.first[:points], 'Boxscore.Points'

    #### Access a Roster
    hs = HoopScrape.new(format: :to_structs)

    roster = hs.roster('UTA')

    # Roster as an array of objects
    r_structs = roster.players
    refute_nil r_structs[1].name,     'Roster.name'
    refute_nil r_structs[1].position, 'Roster.position'
    refute_nil r_structs[1].salary,   'Roster.salary'

    #### Access a Schedule
    schedule = hs.schedule('UTA', year: 2016)         # Gets schedule for latest available season type (Pre/Regular/Post)
    past     = schedule.pastGames         # multidimensional array of completed games
    schedule.futureGames                  # multidimensional array of upcoming games

    assert_equal nil, schedule.nextTeamId, 'Schedule.Next Team'

    hs.schedule('BOS', season: 1)                                  # Get Preseason schedule
    playoffs = hs.schedule('CLE', season: 3, year: 2016, f_mat: :to_structs)   # Get Playoff schedule
    last_game = playoffs.allGames.last
    assert_equal %w(16 5), [last_game.wins, last_game.losses]

    # Past Schedule Games as Objects
    assert_equal 'Oct 28', past.first.date,       'schedule.Game Date'
    assert_equal 'UTA',    past.first.team,       'schedule.Team Abbreviation'
    assert_equal '87',     past.first.team_score, 'schedule.Team Point Total'
    assert_equal '92',     past.first.opp_score,  'schedule.Opponent Point Total'

    #### Access a Player
    player = hs.player(2991473) # Returns an NbaPlayer object
    assert_equal 'Anthony Bennett', player.name,    'Player.name'
    assert_equal '235',             player.weight,  'Player.weight'

    #### Access the NBA Team List
    hs = HoopScrape.new(format: :to_hashes)

    team_list = hs.teamList # multidimensional array of Team info

    assert_equal 'Boston Celtics', team_list.first[:name],     'Team.name'
    assert_equal 'BOS',            team_list.first[:team],     'Team.abbr'
    assert_equal 'Atlantic',       team_list.first[:division], 'Team.div'

    #### Customize field names
    m_rost = S_ROSTER.dup.change_sym!(:name, :full_name).change_sym!(:salary, :crazy_money)
    HoopScrape.roster('CLE').players[].to_structs(m_rost)
    # m_rost = S_ROSTER.dup.change_sym!(:name, :full_name).change_sym!(:salary, :crazy_money)
    # players = HoopScrape.roster('CLE').players[].to_structs(m_rost)
    # assert_equal 'LeBron James', players[4].full_name,   ':full_name => LeBron James'
    # assert_equal '22970500',     players[4].crazy_money, ':crazy_money => 22970500'

    # S_TEAM.replace [:short, :long, :div, :conf]
    # t = HoopScrape.teamList[].to_structs
    # assert_equal 'BOS', t.first.short, '# => BOS'
  end

  def test_chaining
    # Get a Boxscore from a past game        vvvvvvvvvvvvvvvvvvvvv
    HoopScrape.schedule('OKC', season: 2, year: 2016).allGames[42].boxscore(:to_structs).awayPlayers.first.name

    # Get a Roster from a Team ID            vvvvvvvvvvvvvvvvvvvvvv
    HoopScrape.boxscore(400827977).homeTotals[0].roster(:to_hashes).players.first[:name]

    # Get a Schedule from a Team ID            vvvvvvvvvvvvvvvvvvvvvv
    HoopScrape.boxscore(400827977).homeTotals[0].schedule(:to_hashes).pastGames.first.boxscore(:to_structs)

    'uta'.schedule(:to_structs).lastGame.boxscore(:to_hashes)
  end
end
