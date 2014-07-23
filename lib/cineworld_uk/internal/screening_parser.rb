module CineworldUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # parse a single performance
    class ScreeningParser
      DATE_REGEX = /date\=(\d{4})(\d{2})(\d{2})/
      TIME_REGEX = /time\=(\d{2})\:(\d{2})/

      DIMENSION_CSS = '.icon-service-2d, .icon-service-3d'
      BABY_CSS      = '.icon-service-cb'
      DBOX_CSS      = '.icon-service-dx'
      HFR_CSS       = '.icon-service-hfr'
      IMAX_CSS      = '.icon-service-ix'
      KIDS_CSS      = '.icon-service-m4j'

      # @param [String] html a chunk of html
      def initialize(html)
        @html = html.to_s
      end

      # url to book this screening
      # @return [String]
      def booking_url
        return unless bookable?
        'http://www.cineworld.co.uk' + doc.css('a').attribute('href')
      end

      # the dimension of the screening
      # @return [String]
      def dimension
        return unless bookable?
        doc.css(DIMENSION_CSS).text.downcase
      end

      # utc time of the screening
      # @return [Time]
      def time
        return unless bookable?
        timezone.local_to_utc(Time.utc(*date_array + time_array))
      end

      # anything special about the screening
      # @return [Array<String>]
      # @example
      #   Cineworld::Internal::ScreeningParser.new(html).tags
      #   => ["imax"]
      def variant
        return unless bookable?
        [baby, dbox, hfr, imax, kids].compact
      end

      # a attributes of a single screening
      # @return [Hash]
      # @example
      #   Cineworld::Internal::ScreeningParser.new(html).to_hash
      #   => {
      #        booking_url: 'http://...',
      #        dimension:   '2d',
      #        time:        <Time>,
      #        variant:     ['imax']
      #      }
      def to_hash
        return unless bookable?
        {
          booking_url: booking_url,
          dimension:   dimension,
          time:        time,
          variant:     variant
        }
      end

      private

      def baby
        'baby' if doc.css(BABY_CSS).length > 0
      end

      def bookable?
        @bookable ||= doc.css('a.performance').size > 0
      end

      def date_array
        @date_array ||= performance_link_html.match(DATE_REGEX) { [$1, $2, $3] }
      end

      def dbox
        'dbox' if doc.css(DBOX_CSS).length > 0
      end

      def doc
        @doc ||= Nokogiri::HTML(@html)
      end

      def hfr
        'hfr' if doc.css(HFR_CSS).length > 0
      end

      def imax
        'imax' if doc.css(IMAX_CSS).length > 0
      end

      def kids
        'kids' if doc.css(KIDS_CSS).length > 0
      end

      def performance_link_html
        @performance_link_html ||= doc.css('a.performance').to_s
      end

      def time_array
        @time_array ||= performance_link_html.match(TIME_REGEX) { [$1, $2] }
      end

      def timezone
        @timezone ||= TZInfo::Timezone.get('Europe/London')
      end
    end
  end
end
