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

      # Showings
      # @return [Hash]
      # @example
      #   {
      #     "2D" => [Time.utc, Time.utc]
      #   }
      def showings
        tz = TZInfo::Timezone.get('Europe/London')
        @nokogiri_html.css('.schedule .performances > li').inject({}) do |result, li|
          key = performance_varient(li)

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

      def performance_varient(node)
        dimension(node) + "#{ ' D-BOX' if dbox?(node) }#{ ' IMAX' if imax?(node) }"
      end
    end
  end
end
