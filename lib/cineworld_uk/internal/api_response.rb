require 'net/http'
require 'json'
require 'nokogiri'

module CineworldUk
  # @api private
  module Internal
    # @api private
    class ApiResponse
      # Basic cinema list of ids/names
      # @return [String] JSON encoded
      def cinema_list
        fetch_cinemas_from_schema
      end

      # List of dates on which there are screening for this cinema id
      # @param [Integer] id the id of the cinema
      # @return [String] JSON encoded
      def dates(id)
        fetch_dates_placeholder
      end

      # All screenings from a specific cinema on a specific date
      # @param [Integer] cinema_id the id of the cinema
      # @param [Date] date a single date in the future
      # @return [String] JSON encoded
      def performances(cinema_id, date)
        fetch_performances_placeholder
      end

      private

      CIRCUIT_ID = 100868

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

      def fetch_cinemas_from_schema
        uri = URI('https://www.cineworld.co.uk/cinemas/')
        html_body = fetch(uri)
        doc = Nokogiri::HTML(html_body)

        json_ld = doc.at_xpath("//script[@type='application/ld+json']")
        return '[]' unless json_ld

        schema_data = JSON.parse(json_ld.content)
        cinemas = schema_data['itemListElement']&.map do |item|
          theater = item['item']
          {
            'id' => extract_cinema_id_from_url(theater['url']),
            'name' => theater['name'],
            'address' => theater['address'],
            'telephone' => theater['telephone']
          }
        end || []

        JSON.generate(cinemas)
      rescue StandardError => e
        warn "Failed to fetch cinemas: #{e.message}"
        '[]'
      end

      def extract_cinema_id_from_url(url)
        url.match(%r{/theaters/([a-z0-9]+)-})&.captures&.first || ''
      end

      def fetch_dates_placeholder
        dates = []
        (0..13).each do |days_ahead|
          date = Date.today + days_ahead
          dates << { 'date' => date.strftime('%Y-%m-%d') }
        end
        JSON.generate(dates)
      end

      def fetch_performances_placeholder
        '[]'
      end
    end
  end
end
