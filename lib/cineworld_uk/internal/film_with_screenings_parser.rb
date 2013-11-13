module CineworldUk

  # Internal utility classes: Do not use
  # @api private
  module Internal

    # Parses a chunk of HTML to derive movie showing data
    class FilmWithScreeningsParser

      # @param [String] film_html a chunk of html
      def initialize(film_html)
        @nokogiri_html = Nokogiri::HTML(film_html)
      end

      # The film name
      # @return [String]
      def film_name
        name = @nokogiri_html.css('.span5 h1 a,.span7 h1 a, .span7 h1').children[0].to_s

        # screening types
        name = name.gsub 'Take 2 Thursday - ', '' # take 2 thursday
        name = name.gsub 'Autism Friendly Screening: ', '' # remove autism friendly

        # bollywood - remove language from film name
        name = name.gsub ' (Malayalam)', ''
        name = name.gsub ' (Tamil)', ''

        # special screenings
        name = name.gsub 'Bolshoi Ballet Live -', 'Bolshoi:' # bolshoi ballet
        if name.match /\- NT .+ encore/
          name = 'National Theatre: ' + name.gsub(/\- NT .+ encore/, '')
        end
        name = name.gsub 'MET Opera -', 'Met Opera:' # fill out Met Opera
        name = name.gsub 'NT Live:', 'National Theatre:' # National theatre
        name = name.gsub 'Royal Ballet Live:', 'Royal Ballet:' # Royal Ballet

        # fill out Royal Opera House
        if pure_name_match = name.match(/Royal Opera Live\: (.+) \-.+/)
          name = 'Royal Opera House: ' + pure_name_match[1]
        end
        name = name.gsub 'Royal Opera Live:', 'Royal Opera House:'

        name = name.gsub '(Encore Performance)', '' # remove rsc-style encore
        name = name.gsub 'RSC Live:', 'Royal Shakespeare Company:' # globe

        name = name.gsub /\- \d{1,2}\/\d{1,2}\/\d{2,4}/, '' # remove dates
        name = name.gsub /\- \d{1,2}\/\d{1,2}\/\d{2,4}/, '' # remove dates
        name = name.gsub /\n/, '' # remove newlines
        name = name.gsub /\A\s+/, '' # remove leading spaces
        name = name.gsub /\s+\z/, '' # remove trailing spaces
        name = name.squeeze(' ') # spaces compressed
      end

    end
  end
end
