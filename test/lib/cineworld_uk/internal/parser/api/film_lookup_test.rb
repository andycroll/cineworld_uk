require_relative '../../../../../test_helper'
require_relative '../../../../../support/fixture_reader'

describe CineworldUk::Internal::Parser::Api::FilmLookup do
  include Support::FixtureReader

  let(:described_class) { CineworldUk::Internal::Parser::Api::FilmLookup }
  let(:api_response) { Minitest::Mock.new }

  before { WebMock.disable_net_connect! }

  before do
    api_response.expect(:film_list, film_list_json)
    api_response.expect(:film_list_comingsoon, film_list_comingsoon_json)
  end

  describe '#to_hash' do
    subject { described_class.new.to_hash }

    it 'returns a Hash of Film objects, keyed by Integers' do
      CineworldUk::Internal::ApiResponse.stub :new, api_response do
        subject.must_be_instance_of(Hash)
        subject.each do |key, value|
          key.must_be_instance_of(Fixnum)
          value.must_be_instance_of(CineworldUk::Internal::Parser::Api::Film)
        end
      end
    end
  end
end
