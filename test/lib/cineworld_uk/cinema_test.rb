require_relative '../../test_helper'

describe CineworldUk::Cinema do

  before { WebMock.disable_net_connect! }

  describe '.all' do
    subject { CineworldUk::Cinema.all }

    before do
      body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas.html') )
      stub_request(:get, 'http://www.cineworld.co.uk/cinemas').to_return( status: 200, body: body, headers: {} )
    end

    it 'returns an Array of CineworldUK::Cinemas' do
      subject.must_be_instance_of(Array)
      subject.each do |value|
        value.must_be_instance_of(CineworldUk::Cinema)
      end
    end

    it 'returns the correctly sized array' do
      subject.size.must_equal 81
    end
  end

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
