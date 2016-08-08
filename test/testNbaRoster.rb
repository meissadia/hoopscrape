require_relative './test_helper'

class TestNbaRoster < Minitest::Test
  include NbaUrls
  include PrintUtils

  def test_live_data
    team_id = 'UTA'
    roster = NbaRoster.new(team_id: team_id)

    # test Coach
    assert_equal 'Quin Snyder', roster.coach, "Verify Coach => #{roster.coach}"

    # test Players
    assert_equal 11,   roster.players[0].size,    "Roster Columns => Fail\n#{roster.players[0]}"
    assert_equal true, roster.players.size >= 12, 'Roster Player Count => Fail'
  end

  def test_file_data
    roster = NbaRoster.new(file: 'test/data/rosterData.html')
    booker = ['UTA', '33', 'Trevor Booker', '4270', 'PF', '28', '6', '8', '228', 'Clemson', '4775000']

    assert_equal booker,         roster.players[0]
    assert_equal 'Quin Snyder',  roster.coach
    assert_equal 15,             roster.players.size
  end

  def test_struct_navigator
    roster = NbaRoster.new(file: 'test/data/rosterData.html',
                           format: :to_structs)

    assert_equal nil,  roster.players.prev
    assert_equal nil,  roster.players.curr
    assert_equal true, roster.players.next.name   == 'Trevor Booker'
    assert_equal true, roster.players.next.name   == 'Trey Burke'
    assert_equal true, roster.players[].last.name == 'Jeff Withey'
    assert_equal true, roster.players.last.name   == 'Jeff Withey'
    assert_equal true, roster.players.prev.name   == 'Tibor Pleiss'
    assert_equal nil,  roster.players[29]
  end
end
