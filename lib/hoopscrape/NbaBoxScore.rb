require 'date'
require_relative './PrintUtils.rb'

# Access NBA boxscore data
class NbaBoxScore
  include NbaUrls

  # @return [String] Game Date
  attr_reader :gameDate

  # @return [String] Away Team Name
  attr_reader :awayName

  # @return [Navigator] Away Team Stats Array
  # @note (see SymbolDefaults::BOX_P)
  # @see BOX_P
  attr_reader :awayPlayers

  # @return [[String]] Away Team Combined Stats
  # @note (see SymbolDefaults::BOX_T)
  # @see BOX_T
  attr_reader :awayTotals

  # @return [String] Home Team Name
  attr_reader :homeName

  # @return [Navigator] Home Team Stats Array
  # @note (see #awayPlayers)
  # @see BOX_P
  attr_reader :homePlayers

  # @return [[String]] Home Team Combined Stats
  # @note (see #awayTotals)
  # @see BOX_T
  attr_reader :homeTotals

  # Boxscore ID
  attr_reader :id
  attr_reader :awayScore
  attr_reader :homeScore

  # Scrape Box Score Data
  # @param game_id [Integer] Boxscore ID
  # @example
  # 	bs = NbaBoxScore.new(400828035)
  def initialize(args)
    doc = getNokoDoc(args[:game_id], args[:file])
    return if doc.nil?
    @id = args[:game_id].to_s
    @gameDate = readGameDate(doc)
    @awayName, @homeName = readTeamNames(doc)
    return unless @gameDate.index('00:00:00') # Only past games have stats
    @awayPlayers, @awayTotals, @awayScore = readTeamStats(doc, 'away', args[:format])
    @homePlayers, @homeTotals, @homeScore = readTeamStats(doc, 'home', args[:format])
  end

  private

  def getNokoDoc(game_id, file)
    return Nokogiri::HTML(open(file)) if game_id.nil? # Parse File
    Nokogiri::HTML(open(boxScoreUrl + game_id.to_s))  # Parse URL
  end

  # Reads the game date from a Nokogiri::Doc
  # @param d [Nokogiri::HTML::Document]
  # @return [String] Game date
  # @example
  # 	bs.readGameDate(doc) #=> "Mon, Nov 23"
  # @note
  # 	Times will be Local to the system Timezone
  #
  def readGameDate(d)
    date = d.title.split('-')[2].delete(',')
    time = d.xpath('//span[contains(@class,"game-time")]')[0].text.strip rescue ''
    time = '00:00:00' if time == 'Final' || time.empty?
    DateTime.parse(date + ' ' + time).strftime('%Y-%m-%d %H:%M:%S')
  end

  # Reads the team names from a Nokogiri::Doc
  # @param d [Nokogiri::HTML::Document]
  # @return [String, String] Team 1, Team 2
  # @example
  # 	bs.readGameDate(doc)
  #
  def readTeamNames(d)
    names = d.xpath('//div[@class="team-info"]/*/span[@class="long-name" or @class="short-name"]')
    away = names[0].text + ' ' + names[1].text
    home = names[2].text + ' ' + names[3].text
    [away, home]
  end

  # Extract Player Stats
  # @param rows [[Nokogiri::XML::NodeSet]] Cumulative Team Stats
  # @param tid [String] Team ID
  # @return [[String]]  Processed Team Stats
  def processPlayerRows(rows, tid, new_form)
    result = [] # Extracted Player Data
    rows.each_with_index do |row, index|
      curr_row = [tid]	# Team ID

      row.children.each do |cell|	# Process Columns
        c_val = cell.text.strip
        case cell.attribute('class').text
        when 'name'
          curr_row << cell.children[0].attribute('href').text[%r{id/(\d+)}, 1] # Player ID
          curr_row << cell.children[0].text.strip # Player Short Name (i.e. D. Wade)
          curr_row << cell.children[1].text.strip # Position
        when 'fg', '3pt', 'ft'
          # Made-Attempts
          curr_row += c_val.split('-')
        else
          curr_row << c_val
        end
      end

      curr_row << (index < 5).to_s  # Check if Starter
      result << curr_row            # Save processed data
    end
    return result.send(new_form, S_BOX_P) unless new_form.nil?
    result
  end

  # Extract Team Stats
  # @param row [[Nokogiri::XML::NodeSet]] Cumulative Team Stats
  # @param tid [String]  Team ID
  # @return [[String]]   Processed Team Stats
  def processTeamRow(row, tid, new_form)
    result = []
    row.children.each do |cell|
      c_val = cell.text.strip
      case cell.attribute('class').text
      when 'name'
        result << tid
      when 'fg', '3pt', 'ft'
        # Made-Attempts
        result += c_val.split('-')
      else
        next if c_val.empty?
        result << c_val
      end
    end
    return [result.send(new_form, S_BOX_T).first, result.last] unless new_form.nil?
    [result, result.last]
  end

  # Reads the team stats from a Nokogiri::Doc
  # @param d [Nokogiri::HTML::Document]
  # @param id [String] Team selector -> home/away
  # @return [String] Game date
  # @example
  # 	bs.readTeamStats(doc,'away')
  #
  def readTeamStats(d, id, new_form)
    # Extract player tables
    p_tables = d.xpath('//div[@class="sub-module"]/*/table/tbody')

    if id == 'away'
      p_tab = p_tables[0, 2]
      tid = getTid(@awayName)
    else
      p_tab = p_tables[2, 4]
      tid = getTid(@homeName)
    end

    player_rows = p_tab.xpath('tr[not(@class)]') # Ignore TEAM rows
    team_row    = p_tab.xpath('tr[@class="highlight"]')[0] # Ignore Percentage row

    player_stats = processPlayerRows(player_rows, tid, new_form)
    team_totals, team_score = processTeamRow(team_row, tid, new_form)

    [Navigator.new(player_stats), team_totals, team_score]
  end
end
