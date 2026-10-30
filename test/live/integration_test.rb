require_relative 'live_helper'

class LiveCinemaTest < Minitest::Test
  def test_all_returns_cinemas
    cinemas = CineworldUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(CineworldUk::Cinema) })
    assert_operator cinemas.size, :>, 18
    assert_equal 'Brighton', cinemas.detect { |cinema| cinema.id == 14 }.name
  end

  def test_cinemas_have_uk_coordinates
    located = CineworldUk::Cinema.all.select(&:latitude)

    refute_empty located
    located.each do |cinema|
      assert_includes 49.0..61.0, cinema.latitude, "#{cinema.id} #{cinema.name}"
      assert_includes(-9.0..2.0, cinema.longitude, "#{cinema.id} #{cinema.name}")
    end
  end
end

class LivePerformanceTest < Minitest::Test
  def test_at_returns_performances
    tomorrow = Date.today + 1
    performances = CineworldUk::Performance.at(14, from: tomorrow, to: tomorrow)

    assert(performances.all? { |p| p.instance_of?(CineworldUk::Performance) })
    assert_operator performances.count, :>, 10
  end
end
