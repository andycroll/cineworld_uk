module CineworldUk
  # The object representing a single screening on the Cineworld UK website
  class Performance < Cinebase::Performance
    # @!attribute [r] booking_url
    #   @return [String] the booking URL on the cinema website
    # @!attribute [r] cinema_name
    #   @return [String] the cinema name
    # @!attribute [r] cinema_id
    #   @return [String] the cinema id
    # @!attribute [r] dimension
    #   @return [String] 2d or 3d
    # @!attribute [r] film_name
    #   @return [String] the film name

    # @!method initialize(options)
    #   @param [Hash] options options hash
    #   @option options [String] :booking_url (nil) buying url for the screening
    #   @option options [String] :cinema_name name of the cinema
    #   @option options [String] :cinema_id website id of the cinema
    #   @option options [String] :dimension ('2d') dimension of the screening
    #   @option options [String] :film_name name of the film
    #   @option options [Time] :starting_at listed start time of the performance

    # All currently listed films showing at a cinema
    # @param [Integer] cinema_id id of the cinema on the website
    # @return [Array<CineworldUk::Screening>]
    def self.at(cinema_id)
      dates(cinema_id).flat_map do |date|
        performances_on(cinema_id, date).flat_map do |p|
          new cinema_hash(cinema_id).merge(p)
        end
      end
    end

    # @!method showing_on
    #   The date of the screening
    #   @return [Date]

    # @!method starting_at
    #   UTC time of the screening
    #   @return [Time]

    # @!method variant
    #   The kinds of screening (IMAX, kids, baby, senior)
    #   @return <Array[String]>

    # private

    # @api private
    def self.api
      @api ||= Internal::ApiResponse.new
    end
    private_class_method :api

    # @api private
    def self.cinema_hash(cinema_id)
      {
        cinema_id: cinema_id,
        cinema_name: CineworldUk::Cinema.new(cinema_id).name
      }
    end
    private_class_method :cinema_hash

    # @api private
    def self.dates(cinema_id)
      @dates ||= JSON.parse(api.dates(cinema_id))['dates'].map do |str|
        Date.strptime(str, '%Y%m%d')
      end
    end
    private_class_method :dates

    # @api private
    def self.films
      @films ||= Internal::Parser::Api::FilmLookup.new.to_hash
    end
    private_class_method :films

    def self.performances_on(cinema_id, date)
      Internal::Parser::Api::PerformancesByDay.new(cinema_id, date, films).to_a
    end
    private_class_method :performances_on
  end
end
