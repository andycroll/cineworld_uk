require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(color: true)
]

require File.expand_path('../../../lib/cineworld_uk.rb', __FILE__)

describe CineworldUk::Cinema do
  let(:described_class) { CineworldUk::Cinema }

  describe '.all' do
    subject { described_class.all }

    it 'returns an Array of CineworldUK::Cinemas' do
      subject.must_be_instance_of(Array)
      subject.each do |value|
        value.must_be_instance_of(CineworldUk::Cinema)
      end
    end

    it 'returns the correctly sized array' do
      subject.size.must_be :>, 18
    end

    it 'returns the right cinemas' do
      subject.first.name.must_equal 'Aberdeen: Queens Links'
      subject.last.name.must_equal 'Yeovil'
    end
  end
end

describe CineworldUk::Performance do
  let(:described_class) { CineworldUk::Performance }

  describe '.at(cinema_id)' do
    subject { described_class.at(3) }

    it 'returns an array of screenings' do
      subject.must_be_instance_of(Array)
      subject.each do |performance|
        performance.must_be_instance_of(CineworldUk::Performance)
      end
    end

    it 'returns correct number of screenings' do
      subject.count.must_be :>, 10
    end
  end
end
