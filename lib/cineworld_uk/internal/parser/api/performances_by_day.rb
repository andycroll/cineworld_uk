module CineworldUk
  # @api private
  module Internal
    module Parser
      module Api
        # A day of performances, a parser for a single API call
        class PerformancesByDay
          def initialize(cinema_id, date, film_lookup)
            @cinema_id = cinema_id
            @date = date
            @film_lookup = film_lookup
          end

          # Details of performance from single day
          # @return [Array<Hash>] :booking_url, :dimension, :film_name,
          # :starting_at, :variant
          def to_a
            performances.map do |performance|
              film = @film_lookup[performance.film_id]
              {
                booking_url: performance.booking_url,
                dimension: film.dimension,
                film_name: film.name,
                starting_at: utc(performance.starting_at),
                variant: (performance.variant + film.variant).sort
              }
            end
          end

          private

          def performances
            parsed_response.map do |hash|
              Internal::Parser::Api::Performance.new(hash)
            end
          end

          def parsed_response
            JSON.parse(response)['performances']
          end

          def response
            Internal::ApiResponse.new.performances(@cinema_id, @date)
          end

          def utc(time)
            time if time.utc?
            TZInfo::Timezone.get('Europe/London').local_to_utc(time)
          end
        end
      end
    end
  end
end
