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
        NameParser.new(original_name).standardize
      end

      # Showings
      # @return [Hash]
      # @example
      #   {
      #     "2D" => [Time.utc, Time.utc]
      #   }
      def showings
        tz = TZInfo::Timezone.get('Europe/London')
        @nokogiri_html.css('.schedule .performances > li').inject({}) do |result, li|
          key = performance_variant(li)

          if has_bookable_link_node?(li)
            time_array = performance_date_array(li) + performance_time_array(li)
            time = tz.local_to_utc(Time.utc(*time_array))
            result.merge(key => (result[key] || []) << [time, booking_url(li)])
          else
            result
          end
        end
      end

      private

      def booking_url(node)
        'http://www.cineworld.co.uk' + performance_link(node)['href']
      end

      def dbox?(node)
        node.css('.tooltip-box .icon-service-dbox').count > 0
      end

      def dimension(node)
        node.css('.tooltip-box .icon-service-twod, .tooltip-box .icon-service-thrd').text
      end

      def has_bookable_link_node?(node)
        performance_link(node) != nil
      end

      def imax?(node)
        node.css('.tooltip-box .icon-service-imax').count > 0
      end

      def hfr?(node)
        node.css('.tooltip-box .icon-service-hfr').count > 0
      end

      def original_name
        @original_name ||= @nokogiri_html.css('.span5 h1 a,.span7 h1 a, .span7 h1').children[0].to_s
      end

      def performance_date_array(node)
        if has_bookable_link_node?(node)
          match = performance_link_text(node).match(/date\=(\d{4})(\d{2})(\d{2})/)
          [match[1], match[2], match[3]]
        end
      end

      def performance_link(node)
        node.css('a.performance').first
      end

      def performance_link_string(node)
        performance_link(node).to_s
      end

      def performance_link_text(node)
        has_bookable_link_node?(node) ? performance_link_string(node) : nil
      end

      def performance_time_array(node)
        if has_bookable_link_node?(node)
          match = performance_link_text(node).match(/time\=(\d{2})\:(\d{2})/)
          [match[1], match[2]]
        end
      end

      def performance_variant(node)
        dimension(node) + "#{ ' D-BOX' if dbox?(node) }#{ ' IMAX' if imax?(node) }#{ ' HFR' if hfr?(node) }"
      end
    end
  end
end
