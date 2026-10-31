require 'json'

require 'cinebase'
require 'cinebase/vista'

require_relative './cineworld_uk/version'

require_relative './cineworld_uk/internal/api_response'
require_relative './cineworld_uk/internal/guest_token'
require_relative './cineworld_uk/internal/parser/api/cinema_address'
require_relative './cineworld_uk/internal/parser/api/film'
require_relative './cineworld_uk/internal/parser/api/performance'

require_relative './cineworld_uk/internal/title_sanitizer'

require_relative './cineworld_uk/cinema'
require_relative './cineworld_uk/performance'

# cineworld_uk gem
module CineworldUk
  AuthenticationError = Cinebase::Vista::AuthenticationError

  extend Cinebase::Vista::TokenHolder

  # @api private
  def self.guest_token_class
    Internal::GuestToken
  end
end
