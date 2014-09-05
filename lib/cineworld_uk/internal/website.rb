# encoding: UTF-8
require 'open-uri'

module CineworldUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # fetches pages from the cineworld.co.uk website
    class Website
      # get the cinema information page for passed id
      # @return [String]
      def cinema_information(id)
        get("cinemas/#{id}/information")
      end

      # get the cinemas page
      # @return [String]
      def cinemas
        get('cinemas')
      end

      # get the cinema page containing all upcoming films and screenings
      # @return [String]
      def whatson(id)
        get("whatson?cinema=#{id}")
      end

      private

      def get(path)
        open("http://www.cineworld.co.uk/#{path}").read
      end
    end
  end
end
