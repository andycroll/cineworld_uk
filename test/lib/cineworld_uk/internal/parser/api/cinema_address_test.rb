require_relative '../../../../../test_helper'
require_relative '../../../../../support/fixture_reader'

describe CineworldUk::Internal::Parser::Api::CinemaAddress do
  include Support::FixtureReader

  let(:described_class) { CineworldUk::Internal::Parser::Api::CinemaAddress }
  let(:api_response) { Minitest::Mock.new }

  before { WebMock.disable_net_connect! }
  after { WebMock.allow_net_connect! }

  describe '#to_hash' do
    subject { described_class.new(id).to_hash }

    before do
      api_response.expect(:cinema_list, cinema_list_json)
    end

    describe 'passed simple (Brighton)' do
      let(:id) { 14 }

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
      let(:id) { 90 }

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
      let(:id) { 37 }

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

    describe 'passed two line (Leicester Square)' do
      let(:id) { 103 }

      it 'returns address hash' do
        CineworldUk::Internal::ApiResponse.stub :new, api_response do
          subject.must_equal(street_address:   '5-6 Leicester Square',
                             extended_address: nil,
                             locality:         'London',
                             region:           'London',
                             postal_code:      'WC2H 7NA',
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
