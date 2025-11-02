require 'net/http'

module CineworldUk
  # @api private
  module Internal
    # @api private
    class ApiResponse
      # Basic cinema list of ids/names
      # @return [String] JSON encoded
      def cinema_list
        response("cinemas/with-event/until/#{DEFAULT_UNTIL_DATE}")
      end

      # List of dates on which there are screening for this cinema id
      # @param [Integer] id the id of the cinema
      # @return [String] JSON encoded
      def dates(id)
        cinema_id = format_cinema_id(id)
        response("dates/in-cinema/#{cinema_id}/until/#{DEFAULT_UNTIL_DATE}")
      end

      # All screenings from a specific cinema on a specific date
      # @param [Integer] cinema_id the id of the cinema
      # @param [Date] date a single date in the future
      # @return [String] JSON encoded
      def performances(cinema_id, date)
        cinema_id_formatted = format_cinema_id(cinema_id)
        response("film-events/in-cinema/#{cinema_id_formatted}/at-date/#{date.strftime('%Y-%m-%d')}")
      end

      private

      def format_cinema_id(id)
        id.to_s.rjust(3, '0')
      end

      # @api private
      # mixin the default hash
      SITE_ID = '10108'
      DEFAULTS = { attr: '', lang: 'en_GB' }
      DEFAULT_UNTIL_DATE = (Date.today + 365).strftime('%Y-%m-%d')

      def fetch(uri, limit = 10)
        fail ArgumentError, 'too many HTTP redirects' if limit == 0

        uri = URI(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        store = OpenSSL::X509::Store.new
        store.set_default_paths
        http.cert_store = store

        request = Net::HTTP::Get.new(uri)
        response = http.request(request)

        case response
        when Net::HTTPSuccess then response.body
        when Net::HTTPRedirection then fetch(response['location'], limit - 1)
        else
          fail "HTTP Error #{response.code}: #{response.message}"
        end
      end

      def response(path, params = {})
        uri = URI::HTTPS.build(
          host: 'www.cineworld.co.uk',
          path: "/uk/data-api-service/v1/quickbook/#{SITE_ID}/#{path}",
          query: URI.encode_www_form(DEFAULTS.merge(params))
        )
        fetch(uri)
      end
    end
  end
end
