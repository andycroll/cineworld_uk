module CineworldUk
  # @api private
  module Internal
    module Parser
      module Api
        # Parses a string to derive address
        class FilmLookup
          # @return [Hash{Integer => CineworldUk::Internal::Parser::Api::Film}]
          # contains all films & upcoming films keyed by id
          def to_hash
            @to_hash ||= all_films.each_with_object({}) do |item, lookup|
              next if item['edi'].nil?
              lookup[item['edi']] = Film.new(item)
            end
          end

          private

          def all_films
            films_data + comingsoon_data
          end

          def api
            @api ||= CineworldUk::Internal::ApiResponse.new
          end

          def comingsoon_data
            @comingsoon_data ||= JSON.parse(api.film_list_comingsoon)['films']
          end

          def films_data
            @films_data ||= JSON.parse(api.film_list)['films']
          end
        end
      end
    end
  end
end
