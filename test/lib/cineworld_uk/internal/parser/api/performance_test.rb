require_relative '../../../../../test_helper'
require_relative '../../../../../support/fixture_reader'

describe CineworldUk::Internal::Parser::Api::Performance do
  include Support::FixtureReader

  let(:described_class) { CineworldUk::Internal::Parser::Api::Performance }
  let(:data) { random_performance }

  before { WebMock.disable_net_connect! }
  after { WebMock.allow_net_connect! }

  describe '#booking_url' do
    subject { described_class.new(data).booking_url }

    it 'should be a url on the cineworld website' do
      subject.must_match(%r{cineworld.co.uk/booking\?})
    end
  end

  describe '#film_id' do
    subject { described_class.new(data).film_id }

    it 'should be a six digit integer' do
      subject.must_be_instance_of(Fixnum)
      subject.must_be :>, 10_000
    end
  end

  describe '#starting_at' do
    subject { described_class.new(data).starting_at }

    it 'should be a time' do
      subject.must_be_instance_of(Time)
    end
  end

  describe '#variant' do
    subject { described_class.new(data).variant }

    describe 'has "ad" => true' do
      let(:data) { random_performance.merge('ad' => true) }

      it 'includes "audio_described"' do
        subject.must_include('audio_described')
      end
    end

    describe 'has "ss" => true' do
      let(:data) { random_performance.merge('subtitled' => true) }

      it 'includes "subtitled"' do
        subject.must_include('subtitled')
      end
    end
  end

  private

  def random_performance
    JSON.parse(performances_tomorrow_json(3))['performances'].sample
  end
end
