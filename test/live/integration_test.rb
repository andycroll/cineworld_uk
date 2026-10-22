require_relative 'live_helper'

class LiveCinemaTest < Minitest::Test
  def test_all_returns_cinemas
    cinemas = CineworldUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(CineworldUk::Cinema) })
    assert_operator cinemas.size, :>, 18
    assert_equal 'Brighton', cinemas.detect { |cinema| cinema.id == 14 }.name
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
