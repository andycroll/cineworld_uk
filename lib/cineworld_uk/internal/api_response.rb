require 'uri'
require 'net/http'

module CineworldUk
  module Internal
    class ApiResponse
      def cinema_list
        response('cinema/list', full: true)
      end

      def cinema_detail(id)
        response('cinema/detail', cinema: id)
      end

      def film_list
        response('film/list', full: true)
      end

      def film_list_comingsoon
        response('film/list/comingsoon', full: true)
      end

      def performances(cinema_id, date)
        response('performances', cinema: cinema_id,
                                 date: date.strftime('%Y%m%d'))
      end

      private

      DEFAULTS = { key: 'ios', territory: 'GB' }

      def fetch(uri, limit = 10)
        fail ArgumentError, 'too many HTTP redirects' if limit == 0

        case response = Net::HTTP.get_response(URI(uri))
        when Net::HTTPSuccess then response.body
        when Net::HTTPRedirection then fetch(response['location'], limit - 1)
        else response.code
        end
      end

      def response(path, hash)
        uri = URI::HTTP.build(host:  'www2.cineworld.co.uk',
                              path:  "/api/#{path}",
                              query: URI.encode_www_form(hash.merge(DEFAULTS)))
        fetch(uri)
      end
    end
  end
end
