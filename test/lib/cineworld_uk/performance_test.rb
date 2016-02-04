require_relative '../../test_helper'
require_relative '../../support/fixture_reader'

describe CineworldUk::Performance do
  include Support::FixtureReader

  let(:described_class) { CineworldUk::Performance }
  let(:api_response) { Minitest::Mock.new }

  before { WebMock.disable_net_connect! }
  after { WebMock.allow_net_connect! }

  describe '.at(cinema_id)' do
    subject { described_class.at(3) }

    before do
      api_response.expect(:cinema_list, cinema_list_json)
      api_response.expect(:film_list, film_list_json)
      api_response.expect(:film_list_comingsoon, film_list_comingsoon_json)
      api_response.expect(:dates, fake_dates_tomorrow_json, [3])
      api_response.expect(:performances,
                          performances_tomorrow_json(3),
                          [3, Date.today + 1])
    end

    it 'returns an array of performances' do
      CineworldUk::Internal::ApiResponse.stub :new, api_response do
        subject.must_be_instance_of(Array)
        subject.each do |performance|
          performance.must_be_instance_of(described_class)
        end
      end
    end

    it 'returns at least a sensible number' do
      CineworldUk::Internal::ApiResponse.stub :new, api_response do
        subject.count.must_be :>, 5
      end
    end
  end

  describe '.new' do
    subject { described_class.new(options) }

    describe 'simple' do
      let(:options) do
        {
          film_name:   'Iron Man 3',
          cinema_id:   3,
          cinema_name: 'Cineworld Brighton',
          starting_at: Time.utc(2013, 9, 12, 11, 0)
        }
      end

      it 'sets cinema name and film name' do
        subject.film_name.must_equal 'Iron Man 3'
        subject.cinema_name.must_equal 'Cineworld Brighton'
      end

      it 'booking url, dimension & varient are set to defaults' do
        subject.booking_url.must_equal nil
        subject.dimension.must_equal '2d'
        subject.variant.must_equal []
      end
    end
  end

  describe '#dimension' do
    let(:options) do
      {
        film_name:   'Iron Man 3',
        dimension:   '3d',
        cinema_id:   3,
        cinema_name: 'Cineworld Brighton',
        starting_at: Time.utc(2013, 9, 12, 11, 0)
      }
    end

    subject { described_class.new(options).dimension }

    it 'returns 2d or 3d' do
      subject.must_be_instance_of(String)
      subject.must_equal '3d'
    end
  end

  describe '#starting_at' do
    subject { described_class.new(options).starting_at }

    describe 'with utc time' do
      let(:options) do
        {
          film_name:   'Iron Man 3',
          cinema_id:   3,
          cinema_name: 'Cineworld Brighton',
          starting_at: Time.utc(2013, 9, 12, 11, 0)
        }
      end

      it 'returns UTC time' do
        subject.must_be_instance_of Time
        subject.must_equal Time.utc(2013, 9, 12, 11, 0)
      end
    end

    describe 'with non-utc time' do
      let(:options) do
        {
          film_name:   'Iron Man 3',
          cinema_id:   3,
          cinema_name: 'Cineworld Brighton',
          starting_at: Time.new(2013, 9, 12, 11, 0)
        }
      end

      it 'returns UTC time' do
        subject.must_be_instance_of Time
        subject.must_equal Time.utc(2013, 9, 12, 10, 0)
        subject.utc?.must_equal(true)
      end
    end
  end

  describe '#showing_on' do
    let(:options) do
      {
        film_name:   'Iron Man 3',
        cinema_id:   3,
        cinema_name: 'Cineworld Brighton',
        starting_at: Time.utc(2013, 9, 12, 11, 0)
      }
    end

    subject { described_class.new(options).showing_on }

    it 'returns date of showing' do
      subject.must_be_instance_of(Date)
      subject.must_equal Date.new(2013, 9, 12)
    end
  end

  describe '#variant' do
    subject { described_class.new(options).variant }

    let(:options) do
      {
        film_name:   'Iron Man 3',
        cinema_id:   3,
        cinema_name: 'Cineworld Brighton',
        starting_at: Time.utc(2013, 9, 12, 11, 0),
        variant:     ['Kids']
      }
    end

    it 'is an alphabetically ordered array of lower-cased strings' do
      subject.must_be_instance_of Array
      subject.each { |element| element.must_be_instance_of String }
      subject.must_equal %w(kids)
    end
  end
end
