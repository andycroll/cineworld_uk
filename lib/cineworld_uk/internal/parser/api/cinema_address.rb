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

          def address_info
            @address_info ||= cinema_hash['addressInfo'] || {}
          end

          def cinema_hash
            @cinema_hash ||= begin
              cinemas = JSON.parse(cinema_list_response)['body']['cinemas']
              formatted_id = @id.to_s.rjust(3, '0')
              cinemas.find { |c| c['id'] == formatted_id } || {}
            end
          end

          def cinema_list_response
            @cinema_list_response ||=
              CineworldUk::Internal::ApiResponse.new.cinema_list
          end

          def extended_address
            addr2 = address_info['address2']
            addr3 = address_info['address3']

            return nil if london?
            addr2 || addr3
          end

          def locality
            address_info['city']
          end

          def london?
            address_info['city'] == 'London' ||
            cinema_hash['displayName']&.start_with?('London')
          end

          def postal_code
            address_info['postalCode']
          end

          def region
            address_info['state'] || ('London' if london?)
          end

          def street_address
            address_info['address1']
          end
        end
      end
    end
  end
end
