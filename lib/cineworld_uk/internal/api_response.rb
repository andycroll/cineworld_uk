require 'uri'
require 'net/http'

module CineworldUk
  # @api private
  module Internal
    # @api private
    class ApiResponse
      # Basic cinema list of ids/names
      # @return [String] JSON encoded
      def cinema_list
        response('cinema/list', full: true)
      end

      # List of dates on which there are screening for this cinema id
      # @param [Fixnum] id the id of the cinema
      # @return [String] JSON encoded
      def dates(id)
        response('dates', cinema: id)
      end

      # Detail about a specific cinema
      # @param [Fixnum] id the id of the cinema
      # @return [String] JSON encoded
      def cinema_detail(id)
        response('cinema/detail', cinema: id)
      end

      # List of all currently showing films
      # @return [String] JSON encoded
      def film_list
        response('film/list', full: true)
      end

      # List of all upcoming films
      # @return [String] JSON encoded
      def film_list_comingsoon
        response('film/list/comingsoon', full: true)
      end

      # All screenings from a specific cinema on a specific date
      # @param [Fixnum] cinema_id the id of the cinema
      # @param [Date] date a single date in the future
      # @return [String] JSON encoded
      def performances(cinema_id, date)
        response('performances', cinema: cinema_id,
                                 date: date.strftime('%Y%m%d'))
      end

      private

      # @api private
      # mixin the default hash
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
