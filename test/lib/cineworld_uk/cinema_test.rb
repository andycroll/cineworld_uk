require_relative '../../test_helper'

describe CineworldUk::Cinema do
  describe '.new id, name, url' do
    it 'stores id, name, slug and url' do
      cinema = CineworldUk::Cinema.new '3', 'Brighton'
      cinema.id.must_equal 3
      cinema.brand.must_equal 'Cineworld'
      cinema.name.must_equal 'Brighton'
      cinema.slug.must_equal 'brighton'
      cinema.url.must_equal 'http://www.cineworld.co.uk/cinemas/3/information'
    end

    it 'removes "London - " name prefix' do
      cinema = CineworldUk::Cinema.new 79, 'London - The O2, Greenwich'
      cinema.id.must_equal 79
      cinema.name.must_equal 'The O2, Greenwich'
      cinema.slug.must_equal 'the-o2-greenwich'
    end
  end
end
