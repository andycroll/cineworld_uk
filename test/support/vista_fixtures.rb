require 'json'

module Support
  # Hand-written Vista responses served over WebMock. They follow the shape in
  # api_shapes.rb; they are never recorded API output.
  module VistaFixtures
    BASE_URL = 'https://digital-api.cineworld.co.uk/ocapi/v1/'.freeze
    HEADERS = {
      'Authorization' => 'Bearer test-guest-token', 'Connect-Region-Code' => 'GB'
    }.freeze

    private

    def setup_vista
      CineworldUk.token = 'test-guest-token'
      reset_caches
    end

    def teardown_vista
      CineworldUk.token = nil
      reset_caches
    end

    def stub_sites
      stub_request(:get, "#{BASE_URL}sites").with(headers: HEADERS)
                                           .to_return(body: sites_json)
    end

    def stub_showtimes(date, body = showtimes_json)
      stub_request(:get, "#{BASE_URL}showtimes/by-business-date/#{date.iso8601}")
        .with(query: { 'siteIds' => '014' }, headers: HEADERS)
        .to_return(body: body)
    end

    def sites_json
      read_fixture('sites')
    end

    def showtimes_json
      read_fixture('showtimes-014')
    end

    def empty_showtimes_json
      JSON.generate('showtimes' => [],
                    'relatedData' => { 'films' => [], 'attributes' => [], 'sites' => [] })
    end

    def read_fixture(name)
      File.read(File.expand_path("../fixtures/api/#{name}.json", __dir__))
    end

    def reset_caches
      [CineworldUk::Cinema, CineworldUk::Performance].each do |klass|
        klass.instance_variables.each { |name| klass.remove_instance_variable(name) }
      end
    end
  end
end
