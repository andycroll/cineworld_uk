require_relative '../../test_helper'

describe CineworldUk::Cinema do
  let(:website) { Minitest::Mock.new }

  before do
    WebMock.disable_net_connect!
  end

  describe '.all' do
    subject { CineworldUk::Cinema.all }

    before do
      website.expect(:cinemas, cinemas_html)
    end

    it 'returns an Array of CineworldUK::Cinemas' do
      CineworldUk::Internal::Website.stub :new, website do
        subject.must_be_instance_of(Array)
        subject.each do |value|
          value.must_be_instance_of(CineworldUk::Cinema)
        end
      end
    end

    it 'returns the correctly sized array' do
      CineworldUk::Internal::Website.stub :new, website do
        subject.size.must_equal 82
      end
    end
  end

  describe '.find(id)' do
    subject { CineworldUk::Cinema.find(id) }

    describe 'Brighton' do
      let(:id) { 3 }

      before do
        website.expect(:cinemas, cinemas_html)
      end

      it 'returns a cinema' do
        CineworldUk::Internal::Website.stub :new, website do
          subject.must_be_instance_of(CineworldUk::Cinema)

          subject.id.must_equal 3
          subject.brand.must_equal 'Cineworld'
          subject.name.must_equal 'Brighton'
        end
      end
    end
  end

  describe '.new' do
    it 'removes "London - " name prefix' do
      cinema = CineworldUk::Cinema.new 79, 'London - The O2, Greenwich'
      cinema.id.must_equal 79
      cinema.name.must_equal 'The O2, Greenwich'
      cinema.slug.must_equal 'the-o2-greenwich'
    end

    it 'removes " - " and replaces it with a colon ": "' do
      cinema = CineworldUk::Cinema.new 88, 'Glasgow - IMAX at GSC'
      cinema.id.must_equal 88
      cinema.name.must_equal 'Glasgow: IMAX at GSC'
      cinema.slug.must_equal 'glasgow-imax-at-gsc'
    end
  end

  describe '#adr' do
    subject { cinema.adr }

    describe '(brighton)' do
      let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }

      before do
        website.expect(:cinema_information, information_html('brighton'), [3])
      end

      it 'returns the address hash' do
        CineworldUk::Internal::Website.stub :new, website do
          subject.must_equal(
            street_address: 'Brighton Marina',
            extended_address: nil,
            locality: 'Brighton',
            region: 'East Sussex',
            postal_code: 'BN2 5UF',
            country: 'United Kingdom'
          )
        end
      end
    end

    describe '(bristol)' do
      let(:cinema) { CineworldUk::Cinema.new('4', 'Bristol') }

      before do
        website.expect(:cinema_information, information_html('bristol'), [4])
      end

      it 'returns the address hash' do
        CineworldUk::Internal::Website.stub :new, website do
          subject.must_equal(
            street_address: 'Hengrove Leisure Park',
            extended_address: 'Hengrove Way',
            locality: 'Bristol',
            region: nil,
            postal_code: 'BS14 0HR',
            country: 'United Kingdom'
          )
        end
      end
    end
  end

  describe '#extended_address' do
    subject { cinema.extended_address }

    describe '(brighton)' do
      let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }

      before do
        website.expect(:cinema_information, information_html('brighton'), [3])
      end

      it 'returns nil' do
        CineworldUk::Internal::Website.stub :new, website do
          subject.must_be_nil
        end
      end
    end

    describe '(bristol)' do
      let(:cinema) { CineworldUk::Cinema.new('4', 'Bristol') }

      before do
        website.expect(:cinema_information, information_html('bristol'), [4])
      end

      it 'returns the second line' do
        CineworldUk::Internal::Website.stub :new, website do
          subject.must_equal 'Hengrove Way'
        end
      end
    end
  end

  describe '#films' do
    subject { CineworldUk::Cinema.new('3', 'Brighton').films }

    it 'calls out to Screening object' do
      CineworldUk::Film.stub :at, [:film] do
        subject.must_equal([:film])
      end
    end
  end

  describe '#full_name' do
    subject { cinema.full_name }

    describe 'simple name (brighton)' do
      let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }

      it 'returns the brand in the name' do
        subject.must_equal 'Cineworld Brighton'
      end
    end

    describe 'complex name (glasgow imax)' do
      let(:cinema) { CineworldUk::Cinema.new('88', 'Glasgow - IMAX at GSC') }

      it 'returns the brand in the name' do
        subject.must_equal 'Cineworld Glasgow: IMAX at GSC'
      end
    end
  end

  describe '#locality' do
    subject { cinema.locality }

    describe '(brighton)' do
      let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }

      before do
        website.expect(:cinema_information, information_html('brighton'), [3])
      end

      it 'returns the town/city' do
        CineworldUk::Internal::Website.stub :new, website do
          subject.must_equal 'Brighton'
        end
      end
    end

    describe '(bristol)' do
      let(:cinema) { CineworldUk::Cinema.new('4', 'Bristol') }

      before do
        website.expect(:cinema_information, information_html('bristol'), [4])
      end

      it 'returns the town/city' do
        CineworldUk::Internal::Website.stub :new, website do
          subject.must_equal 'Bristol'
        end
      end
    end
  end

  describe '#postal_code' do
    subject { cinema.postal_code }

    describe '(brighton)' do
      let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }

      before do
        website.expect(:cinema_information, information_html('brighton'), [3])
      end

      it 'returns the post code' do
        CineworldUk::Internal::Website.stub :new, website do
          subject.must_equal 'BN2 5UF'
        end
      end
    end
  end

  describe '#region' do
    subject { cinema.region }

    describe '(brighton)' do
      let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }

      before do
        website.expect(:cinema_information, information_html('brighton'), [3])
      end

      it 'returns the county' do
        CineworldUk::Internal::Website.stub :new, website do
          subject.must_equal 'East Sussex'
        end
      end
    end

    describe '(bristol)' do
      let(:cinema) { CineworldUk::Cinema.new('4', 'Bristol') }

      before do
        website.expect(:cinema_information, information_html('bristol'), [4])
      end

      it 'returns nil' do
        CineworldUk::Internal::Website.stub :new, website do
          subject.must_be_nil
        end
      end
    end
  end

  describe '#screenings' do
    subject { CineworldUk::Cinema.new('3', 'Brighton').screenings }

    it 'calls out to Screening object' do
      CineworldUk::Screening.stub :at, [:screening] do
        subject.must_equal([:screening])
      end
    end
  end

  describe '#street_address' do
    subject { cinema.street_address }

    describe '(brighton)' do
      let(:cinema) { CineworldUk::Cinema.new('3', 'Brighton') }

      before do
        website.expect(:cinema_information, information_html('brighton'), [3])
      end

      it 'returns the street address' do
        CineworldUk::Internal::Website.stub :new, website do
          subject.must_equal 'Brighton Marina'
        end
      end
    end
  end

  private

  def read_file(filepath)
    File.read(File.expand_path(filepath, __FILE__))
  end

  def cinemas_html
    read_file('../../../fixtures/cinemas.html')
  end

  def information_html(filename)
    read_file("../../../fixtures/information/#{filename}.html")
  end

  def parse(html)
    Nokogiri::HTML(html)
  end
end
