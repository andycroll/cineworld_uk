require_relative '../../test_helper'

class CineworldUk::PerformanceTest < Minitest::Test
  include Support::VistaFixtures

  DATE = Date.new(2026, 10, 24)

  def setup
    setup_vista
  end

  def teardown
    teardown_vista
    super
  end

  def test_at_returns_performances
    performances = performances_on_date

    assert(performances.all? { |p| p.instance_of?(CineworldUk::Performance) })
    assert_equal 7, performances.count
  end

  def test_at_accepts_string_id
    stub_showtimes(DATE)

    assert_equal 7, CineworldUk::Performance.at('014', from: DATE, to: DATE).count
  end

  def test_at_parses_first_performance
    performance = performances_on_date.first

    assert_equal 14, performance.cinema_id
    assert_equal 'Brighton', performance.cinema_name
    assert_equal 'The Example Film', performance.film_name
    assert_equal Time.utc(2026, 10, 24, 8, 0), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_equal %w(audio_described), performance.variant
    assert_equal 'https://web.cineworld.co.uk/order/showtimes/014-1001/seats',
                 performance.booking_url
  end

  def test_at_keeps_format_per_session
    performances = performances_on_date

    assert_equal '3d', performances[1].dimension
    assert_equal %w(imax), performances[1].variant
    assert_equal '2d', performances.last.dimension
  end

  def test_at_returns_language_and_subtitles
    performance = performances_on_date[2]

    assert_equal 'Imaginary Picture', performance.film_name
    assert_equal 'Tamil', performance.language
    assert performance.subtitled?
  end

  def test_at_marks_movies_for_juniors_as_kids
    performance = performances_on_date[3]

    assert_equal 'Pretend Pups', performance.film_name
    assert_equal %w(kids), performance.variant
  end

  def test_at_moves_festival_from_title
    performance = performances_on_date[4]

    assert_equal 'Scum Of The Earth', performance.film_name
    assert_equal Cinebase::Festival.new(name: 'Cine-Excess', year: 2026), performance.festival
  end

  def test_at_parses_format_and_film_year
    performance = performances_on_date[5]

    assert_equal 'Wildwood', performance.film_name
    assert_equal 2026, performance.film_year
    assert_equal %w(4dx), performance.variant
  end

  def test_new_sets_film_year
    assert_equal 1996, CineworldUk::Performance.new(options(film_year: 1996)).film_year
  end

  def test_at_keeps_after_midnight_on_next_utc_day
    assert_equal Time.utc(2026, 10, 24, 23, 15), performances_on_date.last.starting_at
  end

  def test_at_includes_last_requested_day_without_fetching_sites
    stub_showtimes(DATE, empty_showtimes_json)
    stub_showtimes(DATE + 1)

    performances = CineworldUk::Performance.at(14, from: DATE, to: DATE + 1)

    assert_equal 7, performances.count
    assert_not_requested :get, "#{BASE_URL}sites"
  end

  def test_at_defaults_to_fourteen_days
    (DATE..DATE + 13).each { |date| stub_showtimes(date, empty_showtimes_json) }

    assert_equal [], CineworldUk::Performance.at(14, from: DATE)
    assert_requested :get, %r{showtimes/by-business-date/}, times: 14
  end

  def test_at_rejects_range_ending_before_start
    assert_raises(ArgumentError) { CineworldUk::Performance.at(14, from: DATE, to: DATE - 1) }
  end

  def test_new_sets_names
    performance = CineworldUk::Performance.new(options)

    assert_equal 'Iron Man 3', performance.film_name
    assert_equal 'Cineworld Brighton', performance.cinema_name
  end

  def test_new_sets_defaults
    performance = CineworldUk::Performance.new(options)

    assert_nil performance.booking_url
    assert_equal '2d', performance.dimension
    assert_nil performance.festival
    assert_nil performance.language
    refute performance.subtitled?
    assert_equal [], performance.variant
  end

  def test_dimension
    assert_equal '3d', CineworldUk::Performance.new(options(dimension: '3d')).dimension
  end

  def test_starting_at_keeps_utc
    assert_equal Time.utc(2013, 9, 12, 11, 0), CineworldUk::Performance.new(options).starting_at
  end

  def test_starting_at_converts_local_time_to_utc
    starting_at = CineworldUk::Performance.new(
      options(starting_at: Time.new(2013, 9, 12, 11, 0))
    ).starting_at

    assert_equal Time.utc(2013, 9, 12, 10, 0), starting_at
    assert starting_at.utc?
  end

  def test_showing_on
    assert_equal Date.new(2013, 9, 12), CineworldUk::Performance.new(options).showing_on
  end

  def test_variant_is_sorted_and_lower_case
    assert_equal %w(kids), CineworldUk::Performance.new(options(variant: ['Kids'])).variant
  end

  private

  def options(overrides = {})
    {
      film_name:   'Iron Man 3',
      cinema_id:   3,
      cinema_name: 'Cineworld Brighton',
      starting_at: Time.utc(2013, 9, 12, 11, 0)
    }.merge(overrides)
  end

  def performances_on_date
    stub_showtimes(DATE)
    CineworldUk::Performance.at(14, from: DATE, to: DATE)
  end
end
