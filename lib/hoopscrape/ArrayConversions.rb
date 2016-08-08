# Array Extensions for Type Conversion
class Array
  # Create Hash Array
  # @param keys [Array] Symbols to be used as field names
  # @return [[Hash]] Array<Hash>
  # @example
  #   teams   = es.teamList # Array of Team data
  #   hash_a  = teams.to_hashes
  #   => [{:t_abbr=>"BOS", :t_name=>"Boston Celtics", :division=>"Atlantic", :conference=>"Eastern"} ... ]
  def to_hashes(keys = [])
    return [] if empty?
    two_d = first.is_a? Array # Check for 2D array
    keys = checkKeys(keys, two_d ? first.size : size) # Determine keys
    return [Hash[keys.map.with_index { |key, idx| [key, self[idx]] }]] unless two_d # 1D Array
    map { |ary| Hash[keys.map.with_index { |key, idx| [key, ary[idx]] }] }          # 2D Array
  end

  # Create Struct Array
  # @param keys [Array] Symbols to be used as field names
  # @return [[Struct]] Array<Struct>
  # @example
  #   teams   = es.teamList # Array of Team data
  #   structs = teams.to_structs
  #   => [#<struct t_abbr="BOS", t_name="Boston Celtics", division="Atlantic", conference="Eastern"> ... ]
  def to_structs(keys = [])
    return [] if empty?
    keys = checkKeys(keys, first.size)
    to_hashes(keys).map { |hash| Struct.new(*hash.keys).new(*hash.values) }
  end

  # Determine default field names
  # @param keys [[Symbol]] Field Names
  # @param k_id [Int] Key Identifier
  # @return [[Symbol]]
  def checkKeys(keys, k_id)
    return keys unless keys.empty?
    [S_BOX_P, S_BOX_T, S_GAME_F, S_GAME_P, S_ROSTER, S_TEAM].each do |default|
      return default if default.size.eql?(k_id)
    end
  end

  # Replace old symbol with new symbol in Array
  # @param old_sym [Symbol] Symbol to remove
  # @param new_sym [Symbol] Symbol to add
  def change_sym!(old_sym, new_sym)
    map! { |x| x.eql?(old_sym) ? new_sym : x }
  end

  # Get an NbaBoxscore
  # @param [Symbol] Format
  # @return [NbaBoxscore] Boxscore
  def boxscore(f_mat = nil)
    return nil unless size == S_GAME_P.size
    HoopScrape.boxscore(self[8], f_mat)
  end
end
