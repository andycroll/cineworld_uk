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

  # A raw guest JWT, without the "Bearer " prefix. Never persisted by the gem.
  class << self
    attr_accessor :token

    # Explicit acquisition/renewal; ordinary API calls never launch a subprocess.
    def acquire_token!(curl: nil)
      self.token = Internal::GuestToken.new(curl: curl).fetch
    end
  end
end
