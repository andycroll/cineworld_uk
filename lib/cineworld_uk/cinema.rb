module CineworldUk

  # The object representing a cinema on the Cineworld UK website
  class Cinema

    # @return [String] the brand of the cinema
    attr_reader :brand
    # @return [Integer] the numeric id of the cinema on the Odeon website
    attr_reader :id
    # @return [String] the name of the cinema
    attr_reader :name
    # @return [String] the slug of the cinema
    attr_reader :slug
    # @return [String] the url of the cinema on the Cineworld website
    attr_reader :url

    # @param [Integer, String] id cinema id
    # @param [String] name cinema name
    # @return [CineworldUk::Cinema]
    def initialize(id, name)
      @brand = 'Cineworld'
      @id    = id.to_i
      @name  = name.gsub('London - ','').gsub(' - ', ': ')
      @slug  = @name.downcase.gsub(/[^0-9a-z ]/,'').gsub(/\s+/, '-')
      @url   = "http://www.cineworld.co.uk/cinemas/#{@id}/information"
    end

    # Return basic cinema information for all cinemas
    # @return [Array<CineworldUk::Cinema>]
    # @example
    #   CineworldUk::Cinema.all
    #   #=> [<CineworldUk::Cinema brand="Cineworld" name="Brighton" slug="brighton" id=3 url="...">, <CineworldUk::Cinema brand="Cineworld" name="The O2, Greenwich" slug="the-o2-greenwich" url="...">, ...]
    def self.all
      parsed_cinemas.css('#cinemaId option[value]').map do |option|
        new option['value'], option.text
      end[1..-1]
    end

    # Find a single cinema
    # @param [Integer, String] id the cinema id of the format 3/'3' as used on the cineworld.co.uk website
    # @return [CineworldUk::Cinema, nil]
    # @example
    #   CineworldUk::Cinema.find('3')
    #   #=> <CineworldUk::Cinema brand="Cineworld" name="Brighton" slug="brighton" id=3 url="...">
    def self.find(id)
      id = id.to_i
      return nil unless id > 0

      all.select { |cinema| cinema.id == id }[0]
    end

    # Address of the cinema
    # @return [Hash] of different address parts
    # @example
    #   cinema = CineworldUk::Cinema.find('Dukes_At_Komedia')
    #   cinema.adr
    #   #=> { street_address: '44-47 Gardner Street', extended_address: 'North Laine', locality: 'Brighton', postal_code: 'BN1 1UN', country_name: 'United Kingdom' }
    # @note Uses the standard method naming as at http://microformats.org/wiki/adr
    def adr
      {
        street_address: street_address,
        extended_address: extended_address,
        locality: locality,
        region: region,
        postal_code: postal_code,
        country: 'United Kingdom'
      }
    end
    alias_method :address, :adr

    # The second address line of the cinema
    # @return [String, nil]
    # @example
    #   cinema = CineworldUk::Cinema.find(10)
    #   cinema.extended_address
    #   #=> 'Chelsea'
    #
    #   cinema = CineworldUk::Cinema.find(3)
    #   cinema.extended_address
    #   #=> nil
    # @note Uses the standard method naming as at http://microformats.org/wiki/adr
    def extended_address
       remaining_address * ', ' unless remaining_address.empty?
    end

    # Films with showings scheduled at this cinema
    # @return [Array<OdeonUk::Film>]
    # @example
    #   cinema = OdeonUk::Cinema.find('71')
    #   cinema.films
    #   #=> [<OdeonUk::Film name="Iron Man 3">, <OdeonUk::Film name="Star Trek Into Darkness">]
    def films
      film_nodes.map do |node|
        parser = CineworldUk::Internal::FilmWithScreeningsParser.new node.to_s
        parser.film_name.length > 0 ? CineworldUk::Film.new(parser.film_name) : nil
      end.compact.uniq
    end

    # The name of the cinema including the brand
    # @return [String]
    # @example
    #   cinema = CineworldUk::Cinema.find(88)
    #   cinema.full_name
    #   #=> 'Cineworld Glasgow: IMAX at GSC'
    def full_name
      "#{brand} #{name}"
    end

    # The locality (town) of the cinema
    # @return [String]
    # @example
    #   cinema = CineworldUk::Cinema.find(3)
    #   cinema.locality
    #   #=> 'Brighton'
    # @note Uses the standard method naming as at http://microformats.org/wiki/adr
    def locality
      adr_has_region? && !adr_in_london? ? final_address_array[-2] : final_address_array[-1]
    end

    # Post code of the cinema
    # @return [String]
    # @example
    #   cinema = CineworldUk::Cinema.find(3)
    #   cinema.postal_code
    #   #=> 'BN2 5UF'
    # @note Uses the standard method naming as at http://microformats.org/wiki/adr
    def postal_code
      final_line_array[-2..-1]*' '
    end

    # The region (county) of the cinema if provided
    # @return [String, nil]
    # @example
    #   cinema = CineworldUk::Cinema.find(3)
    #   cinema.region
    #   #=> 'East Sussex'
    # @note Uses the standard method naming as at http://microformats.org/wiki/adr
    def region
      final_line_non_postal_code if adr_has_region? && !adr_in_london?
    end

    # All planned screenings
    # @return [Array<CineworldUk::Screening>]
    # @example
    #   cinema = CineworldUk::Cinema.find(3)
    #   cinema.screenings
    #   # => [<CineworldUk::Screening film_name="Iron Man 3" cinema_name="Brighton" when="..." variant="...">, <CineworldUk::Screening ...>]
    def screenings
      film_nodes.map do |node|
        parser = CineworldUk::Internal::FilmWithScreeningsParser.new node.to_s
        parser.showings.map do |screening_type, times|
          times.map do |array|
            CineworldUk::Screening.new parser.film_name, self.name, array[0], array[1], screening_type
          end
        end
      end.flatten
    end

    # The street adress of the cinema
    # @return a String
    # @example
    #   cinema = CineworldUk::Cinema.find(3)
    #   cinema.street_address
    #   #=> 'Brighton Marina'
    # @note Uses the standard method naming as at http://microformats.org/wiki/adr
    def street_address
      address_parts[0]
    end

    private

    def self.parsed_cinemas
      @parsed_cinemas ||= Nokogiri::HTML(cinemas_response)
    end

    def self.cinemas_response
      @cinemas_response ||= HTTParty.get('http://www.cineworld.co.uk/cinemas')
    end

    def address_parts
      @address_parts ||= parsed_information.css('address.marker').to_s.split('<br>')[-2].split(',').map(&:strip)
    end

    def adr_in_london?
      final_line_non_postal_code == 'London'
    end

    def adr_has_region?
      final_line_non_postal_code != name
    end

    def film_nodes
      @film_nodes ||= parsed_whatson.css('.section.light #filter-reload > .span9').to_s.split('<hr>')
    end

    def final_address_array
      address_parts[0..-2] << final_line_non_postal_code
    end

    def final_line_array
      address_parts[-1].split(' ')
    end

    def final_line_non_postal_code
      final_line_array[0..-3]*' '
    end

    def information_response
      @information_response ||= HTTParty.get("http://www.cineworld.co.uk/cinemas/#{@id}/information")
    end

    def parsed_information
      @parsed_information ||= Nokogiri::HTML(information_response)
    end

    def parsed_whatson
      @parsed_whatson ||= Nokogiri::HTML(whatson_response)
    end

    def remaining_address
      final_address_array.delete_if { |e| e == street_address || e == locality || e == region }
    end

    def whatson_response
      @whatson_response ||= HTTParty.get("http://www.cineworld.co.uk/whatson?cinema=#{@id}")
    end
  end
end
