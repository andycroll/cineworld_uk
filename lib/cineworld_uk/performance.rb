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
    #   Constructor
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
      cinema_id = cinema_id.to_i
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
      @dates ||= JSON.parse(api.dates(cinema_id))['body']['dates'].map do |str|
        Date.strptime(str, '%Y-%m-%d')
      end
    end
    private_class_method :dates

    # @api private
    def self.performances_on(cinema_id, date)
      response = JSON.parse(api.performances(cinema_id, date))
      films_hash = build_films_hash(response['body']['films'])
      events = response['body']['events']

      events.map do |event_data|
        performance = Internal::Parser::Api::Performance.new(event_data)
        film = films_hash[performance.film_id]

        {
          booking_url: performance.booking_url,
          dimension: film.dimension,
          film_name: film.name,
          starting_at: utc(performance.starting_at),
          variant: (performance.variant + film.variant).sort
        }
      end
    end
    private_class_method :performances_on

    # @api private
    def self.build_films_hash(films_array)
      films_array.each_with_object({}) do |film_data, hash|
        film = Internal::Parser::Api::Film.new(film_data)
        hash[film_data['id']] = film
      end
    end
    private_class_method :build_films_hash

    # @api private
    def self.utc(time)
      return time if time.utc?
      TZInfo::Timezone.get('Europe/London').local_to_utc(time)
    end
    private_class_method :utc
  end
end
