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
            @data['bookingLink']
          end

          # @return [Integer] id for film lookup
          def film_id
            @data['filmId']
          end

          # @return [DateTime] in local time
          def starting_at
            Time.parse(@data['eventDateTime'])
          end

          # @return [Array<String>] includes audio described & subtitled
          def variant
            attrs = @data['attributeIds'] || []
            [
              attrs.include?('audio-described') ? 'audio_described' : nil,
              attrs.include?('subbed') ? 'subtitled' : nil
            ].compact
          end
        end
      end
    end
  end
end
