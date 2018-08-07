require_relative './test_helper'

class TestNbaPlayer < Minitest::Test
  include NbaUrls
  NAME = /^\w+\s?\w*$/
  POSITION = /([A-Z]{2,}?)(\/[A-Z]{2,}?)?/
  DIGIT = /^\d+$/
  COLLEGE = /^\w+(?:\s?\w*)*$/
  def test_file_data
    a_bennett = NbaPlayer.new('', 'test/data/playerBennett.html')
    validate_player(a_bennett)
  end

  def test_live_data
    l_james = HoopScrape.player(1966)
    validate_player(l_james)
  end

  def test_live_non_nba
    # Test Non-NBA Player
    player = HoopScrape.player(2585991)
    assert_equal '0', player.age, 'Player Age => Error'

    # Simply validate no runtime errors
    HoopScrape.player(2233514)
    HoopScrape.player(2995725)
    HoopScrape.player(3945381)
  end

  def validate_player(player)
    assert NAME.match(player.name),          'Player Name => Error'
    assert COLLEGE.match(player.college),    'Player College => Error'
    assert POSITION.match(player.position),  'Player Position => Error'
    assert DIGIT.match(player.age),          'Player Age => Error'
    assert DIGIT.match(player.height_ft),    'Player H_FT => Error'
    assert DIGIT.match(player.height_in),    'Player H_IN => Error'
    assert DIGIT.match(player.weight),       'Player Weight => Error'
    assert DIGIT.match(player.id.to_s),      'Player ID => Error'
  end
end
