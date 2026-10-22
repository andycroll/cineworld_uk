require_relative '../../test_helper'

class CineworldUk::CinemaTest < Minitest::Test
  include Support::VistaFixtures

  def setup
    setup_vista
    stub_sites
  end

  def teardown
    teardown_vista
    super
  end

  def test_all_returns_cinemas
    cinemas = CineworldUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(CineworldUk::Cinema) })
    assert_equal [14, 88, 103, 999], cinemas.map(&:id)
  end

  def test_all_fetches_sites_once
    CineworldUk::Cinema.all
    CineworldUk::Cinema.new(14).name

    assert_requested :get, "#{BASE_URL}sites", times: 1
  end

  def test_adr
    expected = {
      street_address: '1 Example Marina',
      extended_address: nil,
      locality: 'Brighton',
      region: 'East Sussex',
      postal_code: 'BN2 0ZZ',
      country: 'United Kingdom'
    }

    assert_equal expected, CineworldUk::Cinema.new(14).adr
    assert_equal expected, CineworldUk::Cinema.new(14).address
  end

  def test_extended_address_is_empty
    assert_equal '', CineworldUk::Cinema.new(14).extended_address
  end

  def test_full_name
    assert_equal 'Cineworld Brighton', CineworldUk::Cinema.new(14).full_name
  end

  def test_full_name_accepts_string_id
    assert_equal 'Cineworld Brighton', CineworldUk::Cinema.new('14').full_name
  end

  def test_full_name_with_multiple_words
    assert_equal 'Cineworld Glasgow Silverburn', CineworldUk::Cinema.new(88).full_name
  end

  def test_name_replaces_dash_separator
    assert_equal 'Example: Riverside', CineworldUk::Cinema.new(999).name
  end

  def test_locality
    assert_equal 'Brighton', CineworldUk::Cinema.new(14).locality
    assert_equal 'London', CineworldUk::Cinema.new(103).locality
  end

  def test_postal_code
    assert_equal 'BN2 0ZZ', CineworldUk::Cinema.new(14).postal_code
  end

  def test_region
    assert_equal 'East Sussex', CineworldUk::Cinema.new(14).region
  end

  def test_region_defaults_to_london_for_london_cinemas
    assert_equal 'London', CineworldUk::Cinema.new(103).region
  end

  def test_street_address
    assert_equal '1 Example Marina', CineworldUk::Cinema.new(14).street_address
  end

  def test_url
    assert_equal 'http://www.cineworld.co.uk/cinemas/14/information',
                 CineworldUk::Cinema.new(14).url
  end
end
