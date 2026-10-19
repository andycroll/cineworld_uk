# frozen_string_literal: true

require "base64"
require "json"
require "nokogiri"
require "open3"

module CineworldUk
  module Internal
    # Retrieves the public guest token without running a browser.
    class GuestToken
      def initialize(curl:)
        @curl = curl || default_curl
      end

      def fetch
        token = extract_token(request_page)
        validate_expiry!(token)
        token
      rescue JSON::ParserError, ArgumentError, IndexError, TypeError, NoMethodError
        raise AuthenticationError, "Guest token page data is missing or invalid", cause: nil
      end

      private

      def default_curl
        bundled = File.expand_path("../../../vendor/curl-impersonate/bin/curl-impersonate", __dir__)
        File.executable?(bundled) ? bundled : "curl-impersonate"
      end

      def curl_command
        [@curl, "--disable", "--impersonate", "chrome150",
         "--compressed", "--silent", "--show-error",
         "--connect-timeout", "10", "--max-time", "30",
         "--write-out", "\n%{http_code}", "https://web.cineworld.co.uk/"]
      end

      def request_page
        output, _stderr, result = Open3.capture3(*curl_command)
        unless result.success?
          raise AuthenticationError,
                "Guest token request failed (curl exit #{result.exitstatus})"
        end

        html, _, status = output.rpartition("\n")
        unless %w[200 404].include?(status)
          raise AuthenticationError, "Guest token page returned HTTP #{status}"
        end
        html
      rescue Errno::ENOENT
        raise AuthenticationError,
              "Install curl-impersonate or pass its executable path with curl:"
      end

      def extract_token(html)
        script = Nokogiri::HTML(html).at_css("script#__NEXT_DATA__")
        data = JSON.parse(script ? script.content : "")
        token = data.dig("props", "pageProps", "environment", "gasToken")
        unless token.is_a?(String) && !token.empty?
          raise AuthenticationError, "Guest token is missing from the page"
        end
        token
      end

      def validate_expiry!(token)
        claims = JSON.parse(Base64.urlsafe_decode64(token.split(".").fetch(1)))
        if Integer(claims.fetch("exp")) <= Time.now.to_i
          raise AuthenticationError, "Guest token supplied by the page has expired"
        end
      end
    end
  end
end
