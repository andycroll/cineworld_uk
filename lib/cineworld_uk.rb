require 'httparty'
require 'nokogiri'
require 'tzinfo'
require 'tzinfo/data'

require_relative './cineworld_uk/version'

require_relative './cineworld_uk/internal/film_with_screenings_parser'
require_relative './cineworld_uk/internal/name_parser'
require_relative './cineworld_uk/internal/titleize'
require_relative './cineworld_uk/internal/screening_parser'
require_relative './cineworld_uk/internal/whatson_parser'
require_relative './cineworld_uk/internal/website'

require_relative './cineworld_uk/cinema'
require_relative './cineworld_uk/film'
require_relative './cineworld_uk/screening'

module CineworldUk
end
