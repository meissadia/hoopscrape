# gems
require 'nokogiri'

# libraries
require 'open-uri'
require 'time'

# Core Extensions
require_relative 'Hash'
require_relative 'Struct'
require_relative 'String'
require_relative 'ArrayConversions' # To Hash | Struct conversions

require_relative 'Navigator'

# hoopscrape
require_relative 'NbaUrls'
require_relative 'NbaBoxScore'
require_relative 'NbaRoster'
require_relative 'NbaTeamList'
require_relative 'NbaSchedule'
require_relative 'NbaPlayer'

# Modules
require_relative 'SymbolDefaults'
require_relative 'PrintUtils'
include SymbolDefaults
include PrintUtils
