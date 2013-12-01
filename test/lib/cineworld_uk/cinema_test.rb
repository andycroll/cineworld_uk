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

  describe '.find(id)' do
    subject { CineworldUk::Cinema.find(id) }

    before do
      body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas.html') )
      stub_request(:get, 'http://www.cineworld.co.uk/cinemas').to_return( status: 200, body: body, headers: {} )
    end

    describe 'Brighton' do
      let(:id) { 3 }

      it 'returns a cinema' do
        subject.must_be_instance_of(CineworldUk::Cinema)

        subject.id.must_equal 3
        subject.brand.must_equal 'Cineworld'
        subject.name.must_equal 'Brighton'
      end
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

  describe '#films' do
    let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }
    subject { cinema.films }

    before do
      body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'whatson', 'brighton.html') )
      stub_request(:get, 'http://www.cineworld.co.uk/whatson?cinema=3').to_return( status: 200, body: body, headers: {} )
    end

    it 'returns an array of films' do
      subject.must_be_instance_of(Array)
      subject.each do |item|
        item.must_be_instance_of(CineworldUk::Film)
      end
    end

    it 'returns correct number of films' do
      subject.count.must_equal 24
    end

    it 'returns uniquely named films' do
      subject.each_with_index do |item, index|
        subject.each_with_index do |jtem, i|
          if index != i
            item.name.wont_equal jtem.name
            item.wont_equal jtem
          end
        end
      end
    end

    it 'returns film objects with correct names' do
      subject.first.name.must_equal 'Gravity'
      subject.last.name.must_equal 'Don Jon'
    end
  end

  describe '#locality' do
    subject { cinema.locality }

    describe '(london o2)' do
      let(:cinema) { CineworldUk::Cinema.new('79', 'The O2, Grenwich') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'the-o2-grenwich.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/79/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the town/city' do
        subject.must_equal 'London'
      end
    end

    describe '(brighton)' do
      let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'brighton.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/3/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the town/city' do
        subject.must_equal 'Brighton'
      end
    end
  end

  describe '#postal_code' do
    subject { cinema.postal_code }

    describe '(brighton)' do
      let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'brighton.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/3/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the post code' do
        subject.must_equal 'BN2 5UF'
      end
    end
  end

  describe '#screenings' do
    let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }
    subject { cinema.screenings }

    before do
      body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'whatson', 'brighton.html') )
      stub_request(:get, 'http://www.cineworld.co.uk/whatson?cinema=3').to_return( status: 200, body: body, headers: {} )
    end

    it 'returns an array of screenings' do
      subject.must_be_instance_of(Array)
      subject.each do |item|
        item.must_be_instance_of(CineworldUk::Screening)
      end
    end

    it 'returns screening objects with correct film names' do
      subject.first.film_name.must_equal 'Gravity'
      subject.last.film_name.must_equal 'Don Jon'
    end

    it 'returns screening objects with correct cinema name' do
      subject.each { |screening| screening.cinema_name.must_equal 'Brighton' }
    end

    it 'returns screening objects with correct UTC times' do
      subject.first.when.must_equal Time.utc(2013, 11, 13, 12, 0, 0)
      subject.last.when.must_equal Time.utc(2013, 11, 21, 21, 30, 0)
    end
  end

  describe '#street_address' do
    subject { cinema.street_address }

    describe '(brighton)' do
      let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'brighton.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/3/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the street address' do
        subject.must_equal 'Brighton Marina'
      end
    end
  end
end
