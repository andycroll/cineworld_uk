require_relative '../../../../../test_helper'

class CineworldUk::Internal::Parser::Api::PerformanceTest < Minitest::Test
  def test_booking_url
    assert_equal 'https://web.cineworld.co.uk/order/showtimes/014-1001/seats',
                 performance.booking_url
  end

  def test_film_id
    assert_equal '014-1001', performance.film_id
  end

  def test_starting_at
    assert_equal Time.utc(2026, 10, 24, 8, 0), performance.starting_at
  end

  def test_language
    assert_equal 'Tamil', performance('language' => 'Tamil').language
  end

  def test_language_defaults_to_nil
    assert_nil performance.language
  end

  def test_variant_audio_described
    assert_includes performance('attributeIds' => ['audio-described']).variant, 'audio_described'
  end

  def test_variant_subtitled
    assert_includes performance('attributeIds' => ['subbed']).variant, 'subtitled'
  end

  private

  def performance(overrides = {})
    data = {
      'filmId' => '014-1001',
      'attributeIds' => [],
      'eventDateTime' => '2026-10-24T08:00:00Z',
      'bookingLink' => 'https://web.cineworld.co.uk/order/showtimes/014-1001/seats'
    }
    CineworldUk::Internal::Parser::Api::Performance.new(data.merge(overrides))
  end
end
