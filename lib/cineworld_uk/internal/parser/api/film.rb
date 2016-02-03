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
            @id = @data['edi']
          end

          # Do you need your 3D glasses?
          # @return [String] either '2d' or '3d'
          def dimension
            @data['format'].match(/3D/i) ? '3d' : '2d'
          end

          # Sanitized film name
          # @return [String]
          def name
            TitleSanitizer.new(@data['originalTitle'] || '').sanitized
          end

          # List of strings representing different kinds of performance, such
          # as autism, kids, imax, members or q&a
          # @return [Array<String>] or an empty array
          def variant
            [
              @data['title'].match(/Autism Friendly/i) ? 'autism_friendly' : nil,
              @data.fetch('format' || '').match(/IMAX/i) ? 'imax' : nil,
              @data['title'].match(/Movies for Juniors/i) ? 'kids' : nil,
              @data['title'].match(/Unlimited Screening/i) ? 'members' : nil,
              @data['title'].match(/Q (and|&) A/i) ? 'q&a' : nil
            ].compact
          end
        end
      end
    end
  end
end
