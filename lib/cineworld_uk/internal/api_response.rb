require "net/http"
require "json"
require "date"
require "time"

module CineworldUk
  module Internal
    # Adapts Vista responses to the parsers' cinema/film/event vocabulary.
    class ApiResponse
      BASE_URL = "https://digital-api.cineworld.co.uk/ocapi/v1/".freeze
      ATTRIBUTES = {
        "3D" => "3d", "IMAX" => "imax", "AD" => "audio-described",
        "Subtitled" => "subbed", "Subtitles" => "subbed",
        "Autism Friendly" => "autism-friendly",
        "Movies for Juniors" => "junior",
        "Unlimited Screening" => "unlimited-screening", "Q&A" => "qa"
      }.freeze

      def cinema_list
        cinemas = fetch("sites").fetch("sites").map do |site|
          address = site.fetch("contactDetails", {}).fetch("addressV2", {})
          {
            "id" => site.fetch("id"),
            "displayName" => site.fetch("name").fetch("text"),
            "addressInfo" => {
              "address1" => address.dig("line1", "text"),
              "city" => address.dig("line2", "text"),
              "state" => address.dig("line3", "text"),
              "postalCode" => address.dig("line4", "text")
            }
          }
        end
        JSON.generate("body" => { "cinemas" => cinemas })
      end

      def performances(cinema_id, date)
        site_id = cinema_id.to_s.rjust(3, "0")
        response = fetch("showtimes/by-business-date/#{date.iso8601}",
                         "siteIds" => site_id)
        related = response.fetch("relatedData")
        films = related.fetch("films").to_h { |film| [film.fetch("id"), film] }
        attributes = related.fetch("attributes").to_h do |attr|
          [attr.fetch("id"), attr]
        end
        normalized_films = []
        events = response.fetch("showtimes").map do |showtime|
          film = films.fetch(showtime.fetch("filmId"))
          attrs = showtime.fetch("attributeIds", []).filter_map do |id|
            attribute = attributes.fetch(id)
            ATTRIBUTES[attribute.dig("shortName", "text")] ||
              ATTRIBUTES[attribute.dig("name", "text")]
          end
          attrs << "3d" if showtime["requires3dGlasses"]
          # Formats belong to a session, not to the film as a whole.
          id = showtime.fetch("id")
          normalized_films << {
            "id" => id,
            "name" => film.fetch("title").fetch("text"),
            "attributeIds" => attrs
          }
          starts_at = showtime.fetch("schedule").fetch("startsAt")
          {
            "filmId" => id, "attributeIds" => attrs,
            "eventDateTime" => Time.iso8601(starts_at).utc.iso8601,
            "bookingLink" =>
              "https://web.cineworld.co.uk/order/showtimes/#{id}/seats"
          }
        end
        site = related.fetch("sites").detect do |item|
          item.fetch("id") == site_id
        end
        JSON.generate(
          "body" => {
            "films" => normalized_films, "events" => events,
            "cinemaName" => site&.dig("name", "text")
          }
        )
      end

      private

      def fetch(path, query = {})
        token = CineworldUk.token
        if !token.is_a?(String) || token.strip.empty?
          raise AuthenticationError,
                "Set CineworldUk.token to a current guest JWT " \
                "before fetching data"
        end
        uri = URI(BASE_URL + path)
        uri.query = URI.encode_www_form(query) unless query.empty?
        request = Net::HTTP::Get.new(uri)
        request["Authorization"] = "Bearer #{token}"
        request["Connect-Region-Code"] = "GB"
        request["Accept"] = "application/json"
        response = Net::HTTP.start(
          uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30
        ) do |http|
          http.request(request)
        end
        case response
        when Net::HTTPSuccess
          JSON.parse(response.body)
        when Net::HTTPUnauthorized
          raise AuthenticationError,
                "Vista rejected the guest token; " \
                "supply a fresh token with CineworldUk.token="
        else
          # Omit response bodies and never redirect credentials to another host.
          raise "Vista HTTP error #{response.code}"
        end
      end
    end
  end
end
