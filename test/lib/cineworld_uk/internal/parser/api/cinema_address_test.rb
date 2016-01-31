require_relative '../../../../../test_helper'
require_relative '../../../../../support/fixture_reader'

describe CineworldUk::Internal::Parser::Api::CinemaAddress do
  include Support::FixtureReader

  let(:described_class) { CineworldUk::Internal::Parser::Api::CinemaAddress }
  let(:api_response) { Minitest::Mock.new }

  before { WebMock.disable_net_connect! }

  describe '#to_hash' do
    subject { described_class.new(id).to_hash }

    before do
      api_response.expect(:cinema_detail, cinema_detail_json(id), [id])
    end

    describe 'passed simple (Brighton)' do
      let(:id) { 3 }

      it 'returns address hash' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          subject.must_equal(street_address:   'Brighton Marina Village',
                             extended_address: nil,
                             locality:         'Brighton',
                             region:           nil,
                             postal_code:      'BN2 5UF',
                             country:          'United Kingdom')
        end
      end
    end

    describe 'passed three line (NEC)' do
      let(:id) { 96 }

      it 'returns address hash' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          subject.must_equal(street_address:   'Resorts World',
                             extended_address: 'Pendigo Way',
                             locality:         'Birmingham',
                             region:           nil,
                             postal_code:      'B40 1PU',
                             country:          'United Kingdom')
        end
      end
    end

    describe 'passed three line (Edinburgh)' do
      let(:id) { 21 }

      it 'returns address hash' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          subject.must_equal(street_address:   'Fountain Park',
                             extended_address: '130/3 Dundee Street',
                             locality:         'Edinburgh',
                             region:           nil,
                             postal_code:      'EH11 1AF',
                             country:          'United Kingdom')
        end
      end
    end

    describe 'passed three line (Chelsea)' do
      let(:id) { 10 }

      it 'returns address hash' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          subject.must_equal(street_address:   '279 Kings Road',
                             extended_address: nil,
                             locality:         'Chelsea',
                             region:           'London',
                             postal_code:      'SW3 5EW',
                             country:          'United Kingdom')
        end
      end
    end

    # describe 'passed non-existant api' do
    #   let(:id) { 0 }
    #
    #   it 'returns hash of nils' do
    #     subject.must_be_instance_of(Hash)
    #     subject.must_equal(street_address:   nil,
    #                        extended_address: nil,
    #                        locality:         "not an address",
    #                        region:           nil,
    #                        postal_code:      "not an address",
    #                        country:          "United Kingdom")
    #   end
    # end
  end
end
