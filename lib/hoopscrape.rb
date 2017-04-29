require_relative 'hoopscrape/requires'

# HoopScrape main class
class HoopScrape
  # Gem Version
  VERSION = '1.0.3'.freeze
  # initialize
  def initialize(config = {})
    @format = defaultFormat(config[:format])
  end

  # Returns an {NbaBoxScore} object
  # @param game_id [Integer] Boxscore ID
  # @return [NbaBoxScore] NbaBoxScore
  # @example
  #   HoopScrape.boxscore(493848273)
  def self.boxscore(game_id, f_mat = nil)
    NbaBoxScore.new(game_id: game_id,
                    format: defaultFormat(f_mat))
  end

  # Returns an {NbaBoxScore} object
  # @param (see .boxscore)
  # @return (see .boxscore)
  # @example
  #  es.boxscore(493848273)
  def boxscore(game_id, f_mat = nil)
    HoopScrape.boxscore game_id, (f_mat || @format)
  end

  # Returns an {NbaRoster} object
  # @param team_id [String] Team ID
  # @return [NbaRoster] NbaRoster
  # @example
  #   HoopScrape.roster('UTA')
  def self.roster(team_id, options = {})
    NbaRoster.new(team_id: team_id,
                  format: defaultFormat(options.fetch(:format, nil)))
  end

  # Returns an {NbaRoster} object
  # @param (see .roster)
  # @return (see .roster)
  # @example
  #  es.roster('UTA')
  #  es.roster('UTA', format: :to_structs)
  def roster(team_id, options = {})
    HoopScrape.roster team_id, format: (options.fetch(:format, nil) || @format)
  end

  # Return Array of Team Data
  # @return [[[String]]] NBA Team Data
  # @example
  #  HoopScrape.teamList(:to_structs)
  def self.teamList(f_mat = nil)
    NbaTeamList.new(format: defaultFormat(f_mat)).teamList
  end

  # Return Array of Team Data
  # @return (see .teamList)
  # @example
  #  es.teamList(:to_structs)
  def teamList(f_mat = nil)
    HoopScrape.teamList(f_mat || @format)
  end

  # Return an {NbaSchedule} object
  # @param team_id [String] Team ID
  # @param options[:season] [Int] Season Type
  # @param options[:year] [Int] Ending Year of Season (i.e. 2016 for 2015-16)
  # @param options[:format] [Sym] Table Format (:to_structs/:to_hashes)
  # @return [NbaSchedule] NbaSchedule
  # @example
  #   HoopScrape.schedule('UTA')            # Schedule for Latest Season Type
  #   HoopScrape.schedule('TOR', s_type: 3) # Playoff Schedule
  def self.schedule(team_id, options = {})
    NbaSchedule.new team_id: team_id,
                    season_type: options[:season],
                    format: defaultFormat(options[:format]),
                    year: options[:year]
  end

  # Return an {NbaSchedule} object
  # @param (see .schedule)
  # @return (see .schedule)
  # @example
  #  es.schedule('MIA')     # Schedule for Latest Season Type
  #  es.schedule('DET', season: 1, year: 2016)  # Preseason Schedule
  def schedule(team_id, options = {})
    HoopScrape.schedule team_id,
                        season: options[:season],
                        format: (options[:format] || @format),
                        year: options[:year]
  end

  # Return new {NbaPlayer} object
  # @param espn_id [String] ESPN Player ID
  # @return [NbaPlayer] NbaPlayer
  # @example
  #   HoopScrape.player(2991473)
  def self.player(espn_id)
    NbaPlayer.new espn_id
  end

  # Return new {NbaPlayer} object
  # @param (see .player)
  # @return (see .player)
  # @example
  #  es.player(2991473)
  def player(espn_id)
    HoopScrape.player espn_id
  end
end
