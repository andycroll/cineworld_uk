module CineworldUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Parses a chunk of HTML to derive movie showing data
    class WhatsonParser
      # css selector for film html chunks
      FILM_CSS       = '#filter-reload > .span9 > .film'

      # @param [Integer] cinema_id cineworld cinema id
      def initialize(cinema_id)
        @cinema_id = cinema_id
      end

      # break up the whats on page into individual chunks for each film
      # @return [Array<String>] html chunks for a film and it's screenings
      def films_with_screenings
        films_html
      end

      private

      def films_html
        whatson_doc.css(FILM_CSS).map { |n| n.to_s.gsub(/^\s+/, '') }
      end

      def whatson
        @whatson ||= CineworldUk::Internal::Website.new.whatson(@cinema_id)
      end

      def whatson_doc
        @whatson_doc ||= Nokogiri::HTML(whatson)
      end
    end
  end
end
