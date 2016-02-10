module CineworldUk
  # The object representing a cinema on the Cineworld UK website
  class Cinema < Cinebase::Cinema
    # @!attribute [r] id
    #   @return [Integer] the numeric id of the cinema on the Cineworld website

    # Constructor
    # @param [Integer, String] id cinema id
    # @return [CineworldUk::Cinema]
    def initialize(id)
      @id = id.to_i
    end

    # Return basic cinema information for all cinemas
    # @return [Array<CineworldUk::Cinema>]
    # @example
    #   CineworldUk::Cinema.all
    #   #=> [<CineworldUk::Cinema>, <CineworldUk::Cinema>, ...]
    def self.all
      id_names_hash.map { |id, _| new id }
    end

    # @api private
    # called from instance methods
    # @return [Hash<Integer => String>]
    def self.id_names_hash
      @id_names_hash ||= cinema_list_json.each_with_object({}) do |hash, result|
        result[hash['id']] =
          hash['name'].gsub('London - ', '').gsub(' - ', ': ')
      end
    end

    # @!method address
    #   Address of the cinema
    #   @return [Hash] of different address parts
    #   @see #adr

    # Address of the cinema
    # @return [Hash] of different address parts
    # @example
    #   cinema = CineworldUk::Cinema.new(3)
    #   cinema.adr
    #   #=> {
    #         street_address: '44-47 Gardner Street',
    #         extended_address: 'North Laine',
    #         locality: 'Brighton',
    #         postal_code: 'BN1 1UN',
    #         country_name: 'United Kingdom'
    #       }
    # @note Uses the standard method naming as at http://microformats.org/wiki/adr
    def adr
      CineworldUk::Internal::Parser::Api::CinemaAddress.new(@id).to_hash
    end

    # Brand of the cinema
    # @return [String] which will always be 'Cineworld'
    # @example
    #   cinema = CineworldUk::Cinema.new(3)
    #   cinema.brand
    #   #=> 'Cineworld'
    def brand
      'Cineworld'.freeze
    end

    # @!method country_name
    #   Country of the cinema
    #   @return [String] which will always be 'United Kingdom'
    #   @example
    #     cinema = CineworldUk::Cinema.new(3)
    #     cinema.country_name
    #     #=> 'United Kingdom'

    # @!method extended_address
    #   The second address line of the cinema
    #   @return [String]
    #   @example
    #     cinema = CineworldUk::Cinema.new(10)
    #     cinema.extended_address
    #     #=> 'Chelsea'
    #
    #     cinema = CineworldUk::Cinema.new(3)
    #     cinema.extended_address
    #     #=> ''

    # @!method full_name
    #   The name of the cinema including the brand
    #   @return [String]
    #   @example
    #     cinema = CineworldUk::Cinema.new(88)
    #     cinema.full_name
    #     #=> 'Cineworld Glasgow: IMAX at GSC'

    # @!method locality
    #   The locality (town) of the cinema
    #   @return [String]
    #   @example
    #     cinema = CineworldUk::Cinema.new(3)
    #     cinema.locality
    #     #=> 'Brighton'

    # The name of the cinema
    # @return [String]
    # @example
    #   cinema = CineworldUk::Cinema.new(3)
    #   cinema.name
    #   #=> 'Brighton'
    def name
      @name ||= self.class.id_names_hash[id]
    end

    # @!method postal_code
    #   Post code of the cinema
    #   @return [String]
    #   @example
    #     cinema = CineworldUk::Cinema.new(3)
    #     cinema.postal_code
    #     #=> 'BN2 5UF'

    # @!method region
    #   The region (county) of the cinema if provided
    #   @return [String]
    #   @example
    #     cinema = CineworldUk::Cinema.new(3)
    #     cinema.region
    #     #=> 'East Sussex'

    # @!method slug
    #   The URL-able slug of the cinema
    #   @return [String]
    #   @example
    #     cinema = CineworldUk::Cinema.new(3)
    #     cinema.slug
    #     #=> 'odeon-brighton'

    # @!method street_address
    #   The street address of the cinema
    #   @return [String]
    #   @example
    #     cinema = CineworldUk::Cinema.new(3)
    #     cinema.street_address
    #     #=> 'Brighton Marina'
    #   @note Uses the standard method naming as at http://microformats.org/wiki/adr

    # The url of the cinema on the Cineworld website
    # @return [String]
    def url
      "http://www.cineworld.co.uk/cinemas/#{@id}/information"
    end

    # private

    # @api private
    def self.api
      @api ||= CineworldUk::Internal::ApiResponse.new
    end
    private_class_method :api

    # @api private
    def self.cinema_list_json
      @cinema_list_json ||=
        JSON.parse(api.cinema_list)['cinemas']
    end
    private_class_method :cinema_list_json
  end
end
