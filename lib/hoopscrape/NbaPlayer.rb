# Read basic bio info from ESPN Player page
class NbaPlayer
  include NbaUrls

  # @return [String] Name
  attr_accessor :name
  # @return [String] Position
  attr_accessor :position
  # @return [Integer] Age
  attr_accessor :age
  # @return [String] College
  attr_accessor :college
  # @return [Integer] Weight
  attr_accessor :weight
  # @return [Integer] Height (ft)
  attr_accessor :h_ft
  # @return [Integer] Height (in)
  attr_accessor :h_in

  # Read Player Data
  def initialize(espn_player_id, file = '')
    espn_player_id = espn_player_id.to_s
    if !espn_player_id.empty?
      url = playerUrl + espn_player_id
      doc = Nokogiri::HTML(open(url))
    else
      doc = Nokogiri::HTML(open(file)) rescue nil
    end
    return if doc.nil?

    readInfo(doc)
  end

  # alias for h_ft
  def height_ft
    @h_ft
  end

  # alias for h_in
  def height_in
    @h_in
  end

  private

  # Extract basic bio info info class attributes
  def readInfo(d)
    @name     = d.xpath("//div[@class='mod-content']/*/h1 | //div[@class='mod-content']/h1")[0].text.strip
    @position = d.xpath("//ul[@class='general-info']/li")[0].text.gsub(/#\d*\s*/, '')
    @college  = d.xpath('//span[text() = "College"]/parent::li').text.gsub('College', '')

    height, weight = gatherHeightWeight(d)

    @weight = processWeight(weight)
    processHeight(height)
    processAge(d)
  end

  def processAge(d)
    /:\s(?<age_num>\d\d)/ =~ d.xpath('//span[text() = "Born"]/parent::li').text
    @age = age_num.to_i.to_s
  end

  def gatherHeightWeight(d)
    h_w = d.xpath("//ul[@class='general-info']/li")[1]
    h_w.text.split(',') unless h_w.nil?
  end

  def processWeight(weight)
    return 0 if weight.nil? || weight.empty?
    weight.strip.split(' ')[0]
  end

  def processHeight(height)
    if !height.nil? && !height.empty?
      @h_ft, @h_in = height.strip.split('\'')
      @h_in = @h_in.delete('"').strip
    else
      @h_ft = @h_in = 0
    end
  end
end
