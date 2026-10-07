require_relative '../../test_helper'
require_relative '../../support/fixture_reader'

describe CineworldUk::Cinema do
  include Support::FixtureReader

  let(:described_class) { CineworldUk::Cinema }
  let(:api_response) { Minitest::Mock.new }

  before { WebMock.disable_net_connect! }
  after { WebMock.allow_net_connect! }

  describe '.all' do
    subject { described_class.all }

    before { api_response.expect(:cinema_list, cinema_list_json) }

    it 'returns an Array of CineworldUK::Cinemas' do
      CineworldUk::Internal::ApiResponse.stub :new, api_response do
        _(subject).must_be_instance_of(Array)
        subject.each do |value|
          _(value).must_be_instance_of(CineworldUk::Cinema)
        end
      end
    end

    it 'returns the correctly sized array' do
      CineworldUk::Internal::ApiResponse.stub :new, api_response do
        _(subject.size).must_equal(87)
      end
    end
  end

  describe '#adr' do
    subject { described_class.new(id).adr }

    before do
      api_response.expect(:cinema_list, cinema_list_json)
    end

    describe 'Brighton (14)' do
      let(:id) { 14 }

      it 'returns the address hash' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          _(subject).must_equal(
            street_address: 'Brighton Marina Village',
            extended_address: nil,
            locality: 'Brighton',
            region: nil,
            postal_code: 'BN2 5UF',
            country: 'United Kingdom'
          )
        end
      end
    end
  end

  describe '#address' do
    subject { described_class.new(id).address }

    before do
      api_response.expect(:cinema_list, cinema_list_json)
    end

    describe 'Brighton (14)' do
      let(:id) { 14 }

      it 'returns the address hash' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          _(subject).must_equal(
            street_address: 'Brighton Marina Village',
            extended_address: nil,
            locality: 'Brighton',
            region: nil,
            postal_code: 'BN2 5UF',
            country: 'United Kingdom'
          )
        end
      end
    end
  end

  describe '#extended_address' do
    subject { described_class.new(id).extended_address }

    before do
      api_response.expect(:cinema_list, cinema_list_json)
    end

    describe 'Brighton (14)' do
      let(:id) { 14 }

      it 'returns the address hash' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          _(subject).must_equal('')
        end
      end
    end
  end

  describe '#full_name' do
    subject { described_class.new(id).full_name }

    before { api_response.expect(:cinema_list, cinema_list_json) }

    describe 'simple name (Brighton)' do
      let(:id) { 14 }

      it 'returns the brand in the name' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          _(subject).must_equal 'Cineworld Brighton'
        end
      end
    end

    describe 'simple name (Brighton) called with String' do
      let(:id) { '14' }

      it 'returns the brand in the name' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          _(subject).must_equal 'Cineworld Brighton'
        end
      end
    end

    describe 'complex name (Glasgow Silverburn)' do
      let(:id) { 88 }

      it 'returns the brand in the name' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          _(subject).must_equal 'Cineworld Glasgow: Silverburn'
        end
      end
    end
  end

  describe '#locality' do
    subject { described_class.new(id).locality }

    before do
      api_response.expect(:cinema_list, cinema_list_json)
    end

    describe 'Brighton (14)' do
      let(:id) { 14 }

      it 'returns the town/city' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          _(subject).must_equal 'Brighton'
        end
      end
    end

    describe 'London - Leicester Square (103)' do
      let(:id) { 103 }

      it 'returns borough of London' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          _(subject).must_equal 'London'
        end
      end
    end
  end

  describe '#postal_code' do
    subject { described_class.new(id).postal_code }

    before do
      api_response.expect(:cinema_list, cinema_list_json)
    end

    describe 'Brighton (14)' do
      let(:id) { 14 }

      it 'returns the post code' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          _(subject).must_equal 'BN2 5UF'
        end
      end
    end
  end

  describe '#region' do
    subject { described_class.new(id).region }

    before do
      api_response.expect(:cinema_list, cinema_list_json)
    end

    describe 'no region - Brighton (14)' do
      let(:id) { 14 }

      it 'returns the empty string is none exists' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          _(subject).must_equal ''
        end
      end
    end

    describe 'London - Leicester Square (103)' do
      let(:id) { 103 }

      it 'returns "London"' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          _(subject).must_equal 'London'
        end
      end
    end
  end

  describe '#street_address' do
    subject { described_class.new(id).street_address }

    before do
      api_response.expect(:cinema_list, cinema_list_json)
    end

    describe 'Brighton (14)' do
      let(:id) { 14 }

      it 'returns the first line of the Address' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          _(subject).must_equal 'Brighton Marina Village'
        end
      end
    end
  end

  describe '#url' do
    subject { described_class.new(id).url }

    before do
      api_response.expect(:cinema_list, cinema_list_json)
    end

    describe 'Brighton (14)' do
      let(:id) { 14 }

      it 'returns the url' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          _(subject).must_equal(
            "http://www.cineworld.co.uk/cinemas/#{id}/information"
          )
        end
      end
    end
  end
end
