module CineworldUk
  # @api private
  module Internal
    module Parser
      module Api
        # Parses a single json hash to produce time details
        class Performance
          # @param [Hash] data from one performance
          # @return [CineworldUk::Internal::Parser::Api::Performance]
          def initialize(data)
            @data = data
          end

          # @return [String] direct booking url
          def booking_url
            "http://www.cineworld.co.uk#{@data['url']}"
          end

          # @return [Integer] id for film lookup
          def film_id
            @data['film']
          end

          # @return [DateTime] in local time
          def starting_at
            Time.strptime(time_str, '%Y%m%d %H:%S')
          end

          # @return [Array<String>] includes audio described & subtitled
          def variant
            [
              @data['ad'] ? 'audio_described' : nil,
              @data['subtitled'] ? 'subtitled' : nil
            ].compact
          end

          private

          def time_str
            "#{@data['date']} #{@data['time']}"
          end
        end
      end
    end
  end
end
