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
      @name  = name.gsub('London - ','')
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

    private

    def self.parsed_cinemas
      Nokogiri::HTML(cinemas_response)
    end

    def self.cinemas_response
      @cinemas_response = HTTParty.get('http://www.cineworld.co.uk/cinemas')
    end

    def film_nodes
      parsed_whatson.css('.section.light #filter-reload > .span9').to_s.split('<hr>')
    end

    def parsed_whatson
      Nokogiri::HTML(whatson_response)
    end

    def whatson_response
      @whatson_response = HTTParty.get("http://www.cineworld.co.uk/whatson?cinema=#{@id}")
    end
  end
end
