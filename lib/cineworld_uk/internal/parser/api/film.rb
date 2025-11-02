module CineworldUk
  # @api private
  module Internal
    module Parser
      module Api
        # Parses a hash to produce film information
        class Film
          # the cineworld id for the film
          attr_reader :id

          # @param [Hash] data parsed from performances JSON
          # @return [ CineworldUk::Internal::Parser::Api::Film]
          def initialize(data)
            @data = data
            @id = @data['id']
          end

          # Do you need your 3D glasses?
          # @return [String] either '2d' or '3d'
          def dimension
            @data['attributeIds']&.include?('3d') ? '3d' : '2d'
          end

          # Sanitized film name
          # @return [String]
          def name
            title = @data['name'] || ''
            TitleSanitizer.new(title).sanitized
          end

          # List of strings representing different kinds of performance, such
          # as autism, kids, imax, members or q&a
          # @return [Array<String>] or an empty array
          def variant
            attrs = @data['attributeIds'] || []
            [
              attrs.include?('autism-friendly') ? 'autism_friendly' : nil,
              attrs.include?('imax') ? 'imax' : nil,
              attrs.include?('junior') ? 'kids' : nil,
              attrs.include?('unlimited-screening') ? 'members' : nil,
              attrs.include?('qa') ? 'q&a' : nil
            ].compact
          end
        end
      end
    end
  end
end
