module CineworldUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Parses a chunk of HTML to derive movie showing data
    class WhatsonParser
      # css selector for all film with screening chunks of html
      FILM_CSS       = '#filter-reload > .span9 > .row:not(.schedule)'
      SCREENINGS_CSS = '#filter-reload > .span9 > .schedule'

      # @param [Integer] cinema_id cineworld cinema id
      def initialize(cinema_id)
        @cinema_id = cinema_id
      end

      # @return [Array<String>] html chunks for a film and it's screenings
      def films_with_screenings
        films_html.each_with_index.map do |html, i|
          html + screenings_html[i]
        end
      end

      private

      def films_html
        whatson_doc.css(FILM_CSS).map { |html| html.to_s.gsub(/^\s+/, '') }
      end

      def screenings_html
        whatson_doc.css(SCREENINGS_CSS).map { |html| html.to_s.gsub(/^\s+/, '') }
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
