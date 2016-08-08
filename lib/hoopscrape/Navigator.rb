# Array Navigator
class Navigator
  # Array of data to Navigate
  attr_reader :list

  # Store array and initialize cursor
  def initialize(list)
    @list    = list
    @bounds  = [-1, list.size]
    @cursor  = -1
  end

  # Return the player located at the current navigation cursor
  # @return [[Object]] Array Element
  def curr
    self[@cursor] if @cursor >= 0
  end

  # Increments the navigation cursor and return the item at that location
  # @return (see #curr)
  def next
    self[(@cursor += 1)]
  end

  # Decrements the navigation cursor and return the item at that location
  # @return (see #curr)
  def prev
    self[(@cursor -= 1)]
  end

  # Updates the navigation cursor if out of bounds. Returns the item at the given location.
  # Returns the underlying array if no index is given.
  # @return [Element] Array Element or Array
  def [](idx = nil)
    return @list if idx.nil?
    @cursor = @bounds[0] if @cursor < @bounds[0]
    @cursor = @bounds[1] if @cursor > @bounds[1]
    @list[idx] if [inbounds?(idx), !@list.nil?].all?
  end

  # Checks if the requested index is within the array bounderies
  def inbounds?(idx)
    (@bounds[0]..@bounds[1]).cover?(idx)
  end

  # Updates the cursor and returns the first element of the array
  def first
    self[@cursor = 0]
  end

  # Updates the cursor and returns the last element of the array
  def last
    self[@cursor = @list.size - 1]
  end

  # Returns the size of the underlying array
  def size
    @list.size
  end
end
