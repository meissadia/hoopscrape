# Extend String
class String
  # Get an NbaRoster
  # @param [Symbol] Format
  # @return [NbaRoster] Roster
  def roster(f_mat = nil)
    HoopScrape.roster(self, format: f_mat)
  end

  # Get an NbaSchedule
  # @param (see #roster)
  # @return [NbaSchedule] Schedule
  def schedule(f_mat = nil)
    HoopScrape.schedule(self, format: f_mat)
  end
end
