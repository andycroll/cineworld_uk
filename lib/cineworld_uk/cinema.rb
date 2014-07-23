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
      @name  = name.gsub('London - ', '').gsub(' - ', ': ')
      @slug  = @name.downcase.gsub(/[^0-9a-z ]/, '').gsub(/\s+/, '-')
      @url   = "http://www.cineworld.co.uk/cinemas/#{@id}/information"
    end

    # Return basic cinema information for all cinemas
    # @return [Array<CineworldUk::Cinema>]
    # @example
    #   CineworldUk::Cinema.all
    #   #=> [<CineworldUk::Cinema brand="Cineworld" name="Brighton" slug="brighton" id=3 url="...">, <CineworldUk::Cinema brand="Cineworld" name="The O2, Greenwich" slug="the-o2-greenwich" url="...">, ...]
    def self.all
      cinemas_doc.css('#cinemaId option[value]').map do |option|
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
      Film.at(id)
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
      if adr_has_region? && !adr_in_london?
        adr_array[-2]
      else
        adr_array[-1]
      end
    end

    # Post code of the cinema
    # @return [String]
    # @example
    #   cinema = CineworldUk::Cinema.find(3)
    #   cinema.postal_code
    #   #=> 'BN2 5UF'
    # @note Uses the standard method naming as at http://microformats.org/wiki/adr
    def postal_code
      last_adr_line_array[-2..-1] * ' '
    end

    # The region (county) of the cinema if provided
    # @return [String, nil]
    # @example
    #   cinema = CineworldUk::Cinema.find(3)
    #   cinema.region
    #   #=> 'East Sussex'
    # @note Uses the standard method naming as at http://microformats.org/wiki/adr
    def region
      last_adr_line_non_postal_code if adr_has_region? && !adr_in_london?
    end

    # All planned screenings
    # @return [Array<CineworldUk::Screening>]
    # @example
    #   cinema = CineworldUk::Cinema.find(3)
    #   cinema.screenings
    #   # => [<CineworldUk::Screening film_name="Iron Man 3" cinema_name="Brighton" when="..." variant="...">, <CineworldUk::Screening ...>]
    def screenings
      Screening.at(id)
    end

    # The street adress of the cinema
    # @return a String
    # @example
    #   cinema = CineworldUk::Cinema.find(3)
    #   cinema.street_address
    #   #=> 'Brighton Marina'
    # @note Uses the standard method naming as at http://microformats.org/wiki/adr
    def street_address
      adr_parts[0]
    end

    private

    def self.cinemas_doc
      @cinemas_doc ||= Nokogiri::HTML(website.cinemas)
    end

    def self.website
      @website ||= CineworldUk::Internal::Website.new
    end

    def adr_array
      adr_parts[0..-2] << last_adr_line_non_postal_code
    end

    def adr_content
      information_doc.css('address.marker').to_s
    end

    def adr_parts
      @parts ||= adr_content.split('<br>')[-2].split(',').map(&:strip)
    end

    def adr_in_london?
      last_adr_line_non_postal_code == 'London'
    end

    def adr_has_region?
      last_adr_line_non_postal_code != name
    end

    def last_adr_line_array
      adr_parts[-1].split(' ')
    end

    def last_adr_line_non_postal_code
      last_adr_line_array[0..-3] * ' '
    end

    def information_doc
      @information_doc ||= begin
        information = CineworldUk::Internal::Website.new.information(@id)
        Nokogiri::HTML(information)
      end
    end

    def remaining_address
      adr_array.delete_if do |e|
        e == street_address || e == locality || e == region
      end
    end
  end
end
