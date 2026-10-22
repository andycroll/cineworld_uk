# frozen_string_literal: true

require "json"
require "nokogiri"

module CineworldUk
  module Internal
    # Reads the public guest token from the ticketing site's page data
    class GuestToken < Cinebase::Vista::GuestToken
      PAGE_URL = "https://web.cineworld.co.uk/"

      private

      # The root page carries the token even when it displays a 404.
      def accepted_statuses
        %w[200 404]
      end

      def bundled_curl
        File.expand_path("../../../vendor/curl-impersonate/bin/curl-impersonate", __dir__)
      end

      def extract_token(html)
        script = Nokogiri::HTML(html).at_css("script#__NEXT_DATA__")
        data = JSON.parse(script ? script.content : "")
        data.dig("props", "pageProps", "environment", "gasToken")
      end
    end
  end
end
