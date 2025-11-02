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
      subject.must_match(%r{cineworld.co.uk})
    end
  end

  describe '#film_id' do
    subject { described_class.new(data).film_id }

    it 'should be a string' do
      subject.must_be_instance_of(String)
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

    describe 'has "audio-described" in attributeIds' do
      let(:data) { random_performance.merge('attributeIds' => ['audio-described']) }

      it 'includes "audio_described"' do
        subject.must_include('audio_described')
      end
    end

    describe 'has "subbed" in attributeIds' do
      let(:data) { random_performance.merge('attributeIds' => ['subbed']) }

      it 'includes "subtitled"' do
        subject.must_include('subtitled')
      end
    end
  end

  private

  def random_performance
    JSON.parse(performances_tomorrow_json(14))['body']['events'].sample
  end
end
