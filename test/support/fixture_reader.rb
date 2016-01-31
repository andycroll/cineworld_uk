module Support
  # Read fixture files from disk, for test support
  module FixtureReader
    private

    FIXTURE_PATH = '../../fixtures/api'

    def cinema_list_json
      read_file("#{FIXTURE_PATH}/cinema-list.json")
    end

    def cinema_detail_json(num)
      read_file("#{FIXTURE_PATH}/cinema-detail-#{num}.json")
    end

    def film_list_comingsoon_json
      read_file("#{FIXTURE_PATH}/film-list-comingsoon.json")
    end

    def film_list_json
      read_file("#{FIXTURE_PATH}/film-list.json")
    end

    def performances_tomorrow_json(num)
      read_file("#{FIXTURE_PATH}/performances-tomorrow-#{num}.json")
    end

    def read_file(filepath)
      File.read(File.expand_path(filepath, __FILE__))
    end
  end
end
