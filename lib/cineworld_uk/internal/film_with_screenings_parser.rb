module CineworldUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Parses a chunk of HTML to derive movie showing data
    class FilmWithScreeningsParser
      # css selector for film name
      FILM_NAME_CSS    = 'h3.h1 a[href*=whatson]'
      # css selector for performances
      PERFORMANCES_CSS = '.schedule .performances > li'

      # @param [String] film_html a chunk of html
      def initialize(film_html)
        @film_html = film_html.to_s
      end

      # The cinema id
      # @return [String]
      def cinema_id
        name_doc.to_s.match(/cinema=(\d+)/)[1].to_i
      end

      # The film name
      # @return [String]
      def film_name
        name_doc.children[0].to_s
      end

      # attributes of all the screenings
      # @return [Array<Hash>]
      def to_a
        performances_doc.map do |node|
          next unless screening_parser_hash(node)
          screening_parser_hash(node).merge(film_hash)
        end.compact
      end

      private

      def doc
        @doc ||= Nokogiri::HTML(@film_html)
      end

      def film_hash
        @film_hash ||= { cinema_id: cinema_id, film_name: film_name }
      end

      def name_doc
        @name_doc ||= doc.css(FILM_NAME_CSS)
      end

      def performances_doc
        @performances_doc ||= doc.css(PERFORMANCES_CSS)
      end

      def screening_parser_hash(node)
        ScreeningParser.new(node).to_hash
      end
    end
  end
end
