module CineworldUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Parses a string to derive a standardized movie title
    class NameParser
      # @return [String] the original name
      attr_reader :original_name

      # @param [String] name original film name
      def initialize(name)
        @original_name = name
        @name = name
      end

      # Process the name and return the final string
      # @return [String]
      def standardize
        strip_and_squeeze
          .ampersands_into_text
          .into_ampersand_if_second_to_last
          .remove_indian_languages
          .remove_screening_details
          .replace_non_film_prefix
          .remove_newlines
          .remove_dates
          .title_case
        to_s
      end

      # The processed name
      # @return [String]
      def to_s
        @name
      end

      protected

      def ampersands_into_text
        _replace(/\s(\&amp;|\&)\s/, ' and ')
        self
      end

      def into_ampersand_if_second_to_last
        _replace(/\s(and)\s(\w+)\z/, ' & \2')
        self
      end

      def remove_indian_languages
        languages = %w(Malayalam Tamil)

        _remove(/\((#{languages * '|'})\)/i)
        self
      end

      def remove_screening_details
        _remove 'Take 2 Thursday - '
        _remove 'Autism Friendly Screening: '
        self
      end

      def remove_dates
        _remove(%r(-? \d{1,2}/\d{1,2}/\d{2,4}))
        self
      end

      def remove_newlines
        _remove(/\n/)
        self
      end

      def replace_non_film_prefix
        _replace 'Bolshoi Ballet Live -', 'Bolshoi:'

        if @name.match(/\- NT .+ encore/)
          @name = 'National Theatre: ' + @name.gsub(/\- NT .+ encore/, '')
        end

        _replace 'NT Live:', 'National Theatre:'

        _replace 'MET Opera -', 'Met Opera:'
        _replace 'Royal Ballet Live:', 'Royal Ballet:'

        # fill out Royal Opera House
        @name.match(/Royal Opera Live\: (.+) \-.+/) do |match|
          @name = 'Royal Opera House: ' + match[1]
        end
        _replace 'Royal Opera Live:', 'Royal Opera House:'

        _replace 'RSC Live:', 'Royal Shakespeare Company:'
        _remove '(Encore Performance)' # remove rsc-style encore

        _remove ' Theatre Series' # West End

        self
      end

      def strip_and_squeeze
        @name = @name.strip.squeeze(' ')
        self
      end

      def title_case
        @name = CineworldUk::Internal::Titleize.titleize(@name)
        self
      end

      private

      def _remove(match)
        @name = @name.gsub(match, '')
      end

      def _replace(match, replacement)
        @name = @name.gsub(match, replacement)
      end
    end
  end
end
