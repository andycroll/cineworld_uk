require_relative 'live_helper'

class LiveApiShapeTest < Minitest::Test
  include ApiShapes

  def test_sites_are_readable
    assert_sites_shape(client.get('sites'))
  end

  def test_showtimes_are_readable
    date = (Date.today + 1).iso8601

    assert_showtimes_shape(client.get("showtimes/by-business-date/#{date}", 'siteIds' => '014'))
  end

  private

  def client
    Cinebase::Vista::Client.new(base_url: CineworldUk::Internal::ApiResponse::BASE_URL,
                                region_code: 'GB', token: CineworldUk.token)
  end
end
