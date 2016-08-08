require_relative './Navigator'
# Access NBA team schedule data
class NbaSchedule
  include NbaUrls
  include PrintUtils

  attr_reader :game_list, :next_game, :year, :wins, :losses

  # Read Schedule data for a given Team
  # @param team_id [String] Team ID
  # @param file [String] HTML Test Data
  # @param season_type [Integer] Season Type
  # @param year [Integer] Ending Year of Season
  # @note
  #  Season Types: 1-Preseason; 2-Regular Season; 3-Playoffs
  # @example
  # 	test     = NbaSchedule.new('', file: 'test/data/testData.html')
  # 	pre      = NbaSchedule.new('UTA', s_type: 1)
  # 	playoffs = NbaSchedule.new('GSW', s_type: 3)
  def initialize(args)
    doc, seasontype = getNokoDoc(args)
    return if doc.nil?

    @game_list = []	# Processed Schedule Data
    @next_game = 0 	# Cursor to start of Future Games

    schedule, @year, indicator, tid = collectNodeSets(doc)
    season_valid = verifySeasonType(seasontype, indicator)
    seasontype   = findSeasonType(indicator) if seasontype.to_i.eql?(0)

    @wins = @losses = 0
    processSeason(schedule, tid, @year, seasontype, args[:format]) if season_valid && !seasontype.eql?(0)
    @allGames    = Navigator.new(@game_list)
    @futureGames = Navigator.new(@game_list[@next_game, game_list.size])
    @pastGames   = Navigator.new(@game_list[0, @next_game])
    @game_list   = nil
    @year = "#{@year}-#{(@year + 1).to_s[2, 4]}"
  end

  # @return [Navigator] Navigator All Schedule data
  # @see GAME_F
  # @see GAME_P
  attr_reader :allGames

  # Returns Schedule info of next game
  # @return [[Object]] Future Schedule Row (Array/Hash/Struct)
  # @note (see #futureGames)
  # @example
  # 	nextGame #=> ['UTA', '13', 'Nov 23', 'true', 'OKC', '9:00 PM ET', 'false', '2015-11-23 21:00:00', '2']
  # @see GAME_F
  def nextGame
    allGames[][@next_game] unless allGames[].nil?
  end

  # Returns Schedule info of last completed game
  # @return [Object] Past Schedule Row (Array/Hash/Struct)
  # @note (see #pastGames)
  # @example
  # 	lastGame #=> ['UTA', '12', '00:00:00', 'false', 'Nov 20', 'false', 'DAL', 'false', '93', '102', '400828071', '6', '6', '2015-11-20 00:00:00', '2']
  # @see SymbolDefaults::GAME_P
  def lastGame
    allGames[][@next_game - 1]
  end

  # @return [Integer] Game # of Next Game
  def nextGameId
    @next_game
  end

  # @return [String] Team ID of next opponent
  # @example
  #   nextTeamId #=> "OKC"
  def nextTeamId
    nextGame[4] if nextGame
  end

  # @return [Navigator] Navigator for Future Games
  # @note (see SymbolDefaults::GAME_F)
  # @see SymbolDefaults::GAME_F
  attr_reader :futureGames

  # Return Schedule info of Past Games
  # @return [Navigator] Navigator for Past Games
  # @note (see SymbolDefaults::GAME_P)
  # @see SymbolDefaults::GAME_P
  attr_reader :pastGames

  private

  # Return Nokogiri XML Document
  def getNokoDoc(args)
    return Nokogiri::HTML(open(args[:file])), args[:season_type] if args[:file] # Use File
    url = formatTeamUrl(args[:team_id], teamScheduleUrl(args[:season_type], args[:year]))
    [Nokogiri::HTML(open(url)), args[:season_type]] # Use Live Data
  end

  # Extract NodeSets
  def collectNodeSets(doc)
    schedule = doc.xpath('//div/div/table/tr') # Schedule Rows
    year     = doc.xpath('//div[@id=\'my-teams-table\']/div/div/div/h1').text.split('-')[1].strip.to_i # Season Starting Year
    season   = doc.xpath("//tr[@class='stathead']").text.split[1].downcase # preseason/regular/postseason
    tid      = getTid(doc.title.split(/\d{4}/)[0].strip).upcase
    [schedule, year, season, tid]
  end

  # Ensure requested season type is what is being processed
  def verifySeasonType(s_type, indicator)
    # If season type is provided, verify
    case s_type
    when 1, 2, 3
      return s_type.eql?(findSeasonType(indicator))
    end
    true
  end

  # Determine season type from document data
  def findSeasonType(indicator)
    # Determine season type
    return 1 if indicator.include?('pre')
    return 2 if indicator.include?('regular')
    return 3 if indicator.include?('post')
    nil
  end

  # Process Table of Schedule Data
  def processSeason(schedule, tid, year1, seasontype, new_form)
    seasontype = seasontype.to_i
    game_id = 0 # 82-game counter

    # Process Schedule lines
    schedule.each do |row|
      game_date = ''
      game_time = ''
      if ('a'..'z').cover?(row.text[1]) # => Non-Header Row
        tmp = [tid, (game_id += 1).to_s] # TeamID, GameID

        if row.children.size == 3                  # => Postponed Game
          game_id -= 1
          next
        elsif row.children[2].text.include?(':')   # => Future Game
          game_date, game_time = futureGame(row, tmp)
          game_in_past = false
        else # => Past Game
          @next_game = game_id
          game_time = '00:00:00'	# Game Time (Not shown for past games)
          game_date = pastGame(row, tmp, seasontype)
          game_in_past = true
        end
      end
      saveProcessedScheduleRow(tmp, formatGameDate(game_date, year1, game_time), seasontype, new_form, game_in_past) unless tmp.nil?
    end
  end

  # Process Past Game Row
  def pastGame(row, result, season_type)
    row.children[0, 4].each_with_index do |cell, cnt|
      txt = cell.text.chomp
      if cnt == 0	# Game Date
        result << txt.split(',')[1].strip
      elsif cnt == 1 			 									# Home Game? and Opponent ID
        saveHomeOpponent(cell, result, txt)
      elsif cnt == 2 			 									# Game Result
        saveGameResult(cell, result, txt)
      else # Team Record
        saveTeamRecord(result, season_type, txt)
      end
    end
    # Game Date
    result[2]
  end

  # Process Future Game Row
  def futureGame(row, result)
    row.children[0, 4].each_with_index do |cell, cnt|
      txt = cell.text.strip
      if cnt == 0 # Game Date
        result << txt.split(',')[1].strip
      elsif cnt == 1 				    # Home/Away, Opp tid
        saveHomeOpponent(cell, result, txt)
      elsif cnt == 2 				    # Game Time
        result << txt + ' ET'
      elsif cnt == 3 			    	# TV
        saveTV(cell, txt, result)
      end
    end
    # Game Date, Game Time
    [result[2], result[5]]
  end

  # Store Home? and Opponent ID
  def saveHomeOpponent(cell, result, txt)
    result << (!txt[0, 1].include?('@')).to_s	# Home Game?
    x0 = cell.children.children.children[1].attributes['href']
    result <<
      if x0.nil? # Non-NBA Team
        cell.children.children.children[1].text.strip
      else # NBA Team
        getTid(x0.text.split('/')[-1].split('-').join(' ')) # Opponent ID
      end
  end

  # Store Game Result
  # Win?, Team Score, Opponent Score, Boxscore ID
  def saveGameResult(cell, result, txt)
    win = (txt[0, 1].include?('W') ? true : false)
    final_score = txt[1, txt.length].gsub(/\s?\d?OT/, '')
    if win
      team_score, opp_score = final_score.split('-')
    else
      opp_score, team_score = final_score.split('-')
    end
    box_id = extract_boxscore_id(cell)
    result << win.to_s << team_score.to_s << opp_score.to_s << box_id  # Win?, Team Score, Opponent Score, Boxcore ID
  end

  def extract_boxscore_id(cell)
    boxscore_id = cell.children.children.children[1].attributes['href']
    return 0 if boxscore_id.nil?
    return boxscore_id.text.split('=')[1] if boxscore_id.text.include?('recap?id=')
    boxscore_id.text.split('/').last
  end

  # Store Team Record
  # Wins, Losses
  def saveTeamRecord(result, season_type, text)
    if season_type == 3 # Team Record Playoffs
      result[5].eql?('true') ? @wins += 1 : @losses += 1
      result << @wins.to_s << @losses.to_s
    else # Team Record Pre/Regular
      wins, losses = text.split('-')
      @wins   = wins.to_i
      @losses = losses.to_i
      result << wins << losses
    end
  end

  # Store TV?
  def saveTV(cell, txt, result)
    # Network image, link or name?
    result << (%w(a img).include?(cell.children[0].node_name) || txt.size > 1).to_s
  end

  # Store Processed Schedule Row
  def saveProcessedScheduleRow(tmp, game_date, season_type, new_form, game_in_past)
    tmp << game_date                    # Game DateTime
    tmp << season_type.to_s             # Season Type
    @game_list << tmp if new_form.nil?  # Save processed Array
    @game_list += tmp.send(new_form, game_in_past ? S_GAME_P : S_GAME_F) unless new_form.nil? # Conversion
  end

  #  Adjust and format dates
  def formatGameDate(month_day, year, game_time = '00:00:00')
    year += 1 unless %w(Oct Nov Dec).include?(month_day.split[0])
    d = DateTime.parse(game_time + ' , ' + month_day + ',' + year.to_s)
    d.strftime('%Y-%m-%d %H:%M:%S') # Game DateTime String
  end
end
