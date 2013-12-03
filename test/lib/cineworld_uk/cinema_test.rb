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

  describe '#adr' do
    subject { cinema.adr }

    describe '(brighton)' do
      let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'brighton.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/3/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the address hash' do
        subject.must_equal({
          street_address: 'Brighton Marina',
          extended_address: nil,
          locality: 'Brighton',
          region: 'East Sussex',
          postal_code: 'BN2 5UF',
          country: 'United Kingdom'
        })
      end
    end

    describe '(bristol)' do
      let(:cinema) { CineworldUk::Cinema.new('4', 'Bristol') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'bristol.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/4/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the address hash' do
        subject.must_equal({
          street_address: 'Hengrove Leisure Park',
          extended_address: 'Hengrove Way',
          locality: 'Bristol',
          region: nil,
          postal_code: 'BS14 0HR',
          country: 'United Kingdom'
        })
      end
    end

    describe '(bury st edmunds)' do
      let(:cinema) { CineworldUk::Cinema.new('6', 'Bury St. Edmunds') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'bury-st-edmunds.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/6/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the address hash' do
        subject.must_equal({
          street_address: 'Parkway',
          extended_address: nil,
          locality: 'Bury St. Edmunds',
          region: nil,
          postal_code: 'IP33 3BA',
          country: 'United Kingdom'
        })
      end
    end

    describe '(london chelsea)' do
      let(:cinema) { CineworldUk::Cinema.new('10', 'London - Chelsea') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'chelsea.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/10/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the address hash' do
        subject.must_equal({
          street_address: '279 Kings Road',
          extended_address: 'Chelsea',
          locality: 'London',
          region: nil,
          postal_code: 'SW3 5EW',
          country: 'United Kingdom'
        })
      end
    end

    describe '(london o2)' do
      let(:cinema) { CineworldUk::Cinema.new('79', 'The O2, Grenwich') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'the-o2-grenwich.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/79/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the address hash' do
        subject.must_equal({
          street_address: 'The O2',
          extended_address: 'Peninsula Square',
          locality: 'London',
          region: nil,
          postal_code: 'SE10 0DX',
          country: 'United Kingdom'
        })
      end
    end
  end

  describe '#extended_address' do
    subject { cinema.extended_address }

    describe '(brighton)' do
      let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'brighton.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/3/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns nil' do
        subject.must_be_nil
      end
    end

    describe '(bristol)' do
      let(:cinema) { CineworldUk::Cinema.new('4', 'Bristol') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'bristol.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/4/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the second line' do
        subject.must_equal 'Hengrove Way'
      end
    end

    describe '(bury st edmunds)' do
      let(:cinema) { CineworldUk::Cinema.new('6', 'Bury St. Edmunds') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'bury-st-edmunds.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/6/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the town/city' do
        subject.must_be_nil
      end
    end

    describe '(london chelsea)' do
      let(:cinema) { CineworldUk::Cinema.new('10', 'London - Chelsea') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'chelsea.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/10/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the second line' do
        subject.must_equal 'Chelsea'
      end
    end

    describe '(london o2)' do
      let(:cinema) { CineworldUk::Cinema.new('79', 'The O2, Grenwich') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'the-o2-grenwich.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/79/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the second line' do
        subject.must_equal 'Peninsula Square'
      end
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

    describe '(bristol)' do
      let(:cinema) { CineworldUk::Cinema.new('4', 'Bristol') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'bristol.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/4/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the town/city' do
        subject.must_equal 'Bristol'
      end
    end

    describe '(bury st edmunds)' do
      let(:cinema) { CineworldUk::Cinema.new('6', 'Bury St. Edmunds') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'bury-st-edmunds.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/6/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the town/city' do
        subject.must_equal 'Bury St. Edmunds'
      end
    end

    describe '(london chelsea)' do
      let(:cinema) { CineworldUk::Cinema.new('10', 'London - Chelsea') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'chelsea.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/10/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the town/city' do
        subject.must_equal 'London'
      end
    end

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

  describe '#region' do
    subject { cinema.region }

    describe '(brighton)' do
      let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'brighton.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/3/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns the county' do
        subject.must_equal 'East Sussex'
      end
    end

    describe '(bristol)' do
      let(:cinema) { CineworldUk::Cinema.new('4', 'Bristol') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'bristol.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/4/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns nil' do
        subject.must_be_nil
      end
    end

    describe '(bury st edmunds)' do
      let(:cinema) { CineworldUk::Cinema.new('6', 'Bury St. Edmunds') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'bury-st-edmunds.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/6/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns nil' do
        subject.must_be_nil
      end
    end

    describe '(london o2)' do
      let(:cinema) { CineworldUk::Cinema.new('79', 'The O2, Grenwich') }

      before do
        body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'cinemas', 'the-o2-grenwich.html') )
        stub_request(:get, 'http://www.cineworld.co.uk/cinemas/79/information').to_return( status: 200, body: body, headers: {} )
      end

      it 'returns nil' do
        subject.must_be_nil
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
