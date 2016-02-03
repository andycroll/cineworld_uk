module CineworldUk
  # @api private
  module Internal
    module Parser
      module Api
        # Parses a string to derive address
        class CinemaAddress
          # @param [Integer] id the cinema id
          # @return [CineworldUk::Internal::Parser::Api::CinemaAddress]
          def initialize(id)
            @id = id
          end

          # @return [Hash] contains :street_address, :extended_address,
          # :locality, :postal_code, :country
          # @note Uses the address naming from http://microformats.org/wiki/adr
          def to_hash
            {
              street_address:   street_address,
              extended_address: extended_address,
              locality:         locality,
              region:           region,
              postal_code:      postal_code,
              country:          'United Kingdom'.freeze
            }
          end

          private

          def adr_array
            @adr_array ||=
              cinema_detail_hash['address'].split(',').map(&:strip).compact
          end

          def cinema_detail_hash
            @cinema_detail_hash ||= JSON.parse(cinema_detail_response)['cinema']
          end

          def cinema_detail_response
            @cinema_detail_response ||=
              CineworldUk::Internal::ApiResponse.new.cinema_detail(@id)
          end

          def ext_array
            @ext_array ||= adr_array[1..-1]
          end

          def extended_address
            return nil if ext_array.count == 1
            london? ? nil : ext_array[0]
          end

          def final
            @final ||= ext_array.last
          end

          def locality
            return ext_array[0] if ext_array.count == 1
            london? ? ext_array[0] : ext_array[1]
          end

          def london?
            final == 'London'
          end

          def postal_code
            cinema_detail_hash['postcode']
          end

          def region
            'London' if london?
          end

          def street_address
            adr_array[0]
          end
        end
      end
    end
  end
end
