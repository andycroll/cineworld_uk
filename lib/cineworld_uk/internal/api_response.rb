# frozen_string_literal: true

require "json"
require "date"
require "time"

module CineworldUk
  module Internal
    # Adapts Vista responses to the parsers' cinema/film/event vocabulary.
    class ApiResponse
      BASE_URL = "https://digital-api.cineworld.co.uk/ocapi/v1/"
      ATTRIBUTES = {
        "3D" => "3d", "IMAX" => "imax", "AD" => "audio-described",
        "Subtitled" => "subbed", "Subtitles" => "subbed",
        "Autism Friendly" => "autism-friendly",
        "Movies for Juniors" => "junior",
        "Unlimited Screening" => "unlimited-screening", "Q&A" => "qa",
        "4DX" => "4dx", "4DX 3D" => "4dx", "ScreenX" => "screenx"
      }.freeze
      LANGUAGES = Cinebase::TitleSanitizer::LANGUAGES

      def cinema_list
        cinemas = fetch("sites").fetch("sites").map do |site|
          address = site.fetch("contactDetails", {}).fetch("addressV2", {})
          {
            "id" => site.fetch("id"),
            "displayName" => site.fetch("name").fetch("text"),
            "location" => site["location"],
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
          language = showtime.fetch("attributeIds", []).filter_map do |id|
            attributes.fetch(id).dig("shortName", "text")
          end.find { |name| LANGUAGES.include?(name) }
          # Formats belong to a session, not to the film as a whole.
          id = showtime.fetch("id")
          normalized_films << {
            "id" => id,
            "name" => film.fetch("title").fetch("text"),
            "attributeIds" => attrs
          }
          starts_at = showtime.fetch("schedule").fetch("startsAt")
          {
            "filmId" => id, "attributeIds" => attrs, "language" => language,
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
        client.get(path, query)
      rescue Cinebase::Vista::AuthenticationError
        CineworldUk.reject_token!(@client_token)
        raise
      end

      # One client keeps one connection open, so reuse it until the token changes.
      def client
        token = CineworldUk.token
        if @client.nil? || @client_token != token
          @client_token = token
          @client = Cinebase::Vista::Client.new(base_url: BASE_URL, region_code: "GB", token: token)
        end
        @client
      end
    end
  end
end
