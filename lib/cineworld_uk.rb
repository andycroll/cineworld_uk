require 'nokogiri'
require 'tzinfo'
require 'tzinfo/data'

require_relative './cineworld_uk/version'

require_relative './cineworld_uk/internal/api_response'
require_relative './cineworld_uk/internal/parser/api/cinema_address'

require_relative './cineworld_uk/internal/film_with_screenings_parser'
require_relative './cineworld_uk/internal/screening_parser'
require_relative './cineworld_uk/internal/title_sanitizer'
require_relative './cineworld_uk/internal/whatson_parser'
require_relative './cineworld_uk/internal/website'

require_relative './cineworld_uk/cinema'
require_relative './cineworld_uk/film'
require_relative './cineworld_uk/screening'

# cineworld_uk gem
module CineworldUk
end
