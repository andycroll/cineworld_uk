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

    private

    def self.parsed_cinemas
      Nokogiri::HTML(cinemas_response)
    end

    def self.cinemas_response
      @cinemas_response = HTTParty.get('http://www.cineworld.co.uk/cinemas')
    end
  end
end
