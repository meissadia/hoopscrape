# Extend Struct
class Struct
  # Get an NbaBoxscore
  # @param [Symbol] Format
  # @return [NbaBoxscore] Boxscore
  def boxscore(f_mat = nil)
    HoopScrape.boxscore(boxscore_id, (f_mat || :to_structs))
  end
end
