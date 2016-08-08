# Field Symbol Defaults for Array Type Conversion
module SymbolDefaults
  # @note Field Symbols for {NbaBoxScore#homePlayers} and {NbaBoxScore#awayPlayers}
  # [Team ID, ESPN Player ID, Player Name (short),  Position, Minutes, Field Goals Made, Field Goals Attempted, 3P Made, 3P Attempted, Free Throws Made, Free Throws Attempted, Offensive Rebounds, Defensive Rebounds, Total Rebounds, Assists, Steals, Blocks, Turnovers, Personal Fouls, Plus/Minus, Points, Starter?]
  S_BOX_P = [:team, :id, :name, :position, :minutes, :fgm, :fga, :tpm, :tpa, :ftm, :fta, :oreb, :dreb, :rebounds, :assists, :steals, :blocks, :turnovers, :fouls, :plusminus, :points, :starter]

  # @note Field Symbols for {NbaBoxScore#homeTotals} and {NbaBoxScore#awayTotals}
  # [Team ID, Field Goals Made, Field Goals Attempted, 3P Made, 3P Attempted, Free Throws Made, Free Throws Attempted, Offensive Rebounds, Defensive Rebounds, Total Rebounds, Assists, Steals, Blocks, Turnovers, Personal Fouls, Plus/Minus, Points, Starter?]
  S_BOX_T = [:team, :fgm, :fga, :tpm, :tpa, :ftm, :fta, :oreb, :dreb, :rebounds, :assists, :steals, :blocks, :turnovers, :fouls, :points]

  # @note Field Symbols for {NbaSchedule#futureGames}
  # [Team ID, Game #, Game Date, Home Game?, Opponent ID, Game Time, Televised?, Game DateTime, Season Type]
  S_GAME_F = [:team, :game_num, :date, :home, :opponent, :time,  :tv, :datetime, :season_type]

  # @note Field Symbols for {NbaSchedule#pastGames}
  # [Team ID, Game #, Game Date, Home Game?, Opponent ID, Win?, Team Score, Opp Score, Boxscore ID, Wins, Losses, Game DateTime, Season Type]
  S_GAME_P = [:team, :game_num, :date, :home, :opponent, :win, :team_score, :opp_score, :boxscore_id, :wins, :losses, :datetime, :season_type]

  # @note Field Symbols for {NbaRoster#players}
  # [Team ID, Jersey #, Player Name, ESPN Player ID, Position, Age, Height ft, Height in, Weight, College, Salary]
  S_ROSTER = [:team, :jersey, :name, :id, :position, :age, :height_ft, :height_in, :weight, :college, :salary]

  # @note Field Symbols for {NbaTeamList#teamList}
  # [Team ID, Team Name, Division, Conference]
  S_TEAM = [:team, :name, :division, :conference]

  # Returns a default structure format
  def defaultFormat(f_mat)
    return f_mat if [:to_structs, :to_hashes].any? { |x| x.eql?(f_mat) }
  end
end
