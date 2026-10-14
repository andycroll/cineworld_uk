require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(color: true)
]

require File.expand_path('../../../lib/cineworld_uk.rb', __FILE__)
CineworldUk.token = ENV.fetch('CINEWORLD_TOKEN')

describe CineworldUk::Cinema do
  let(:described_class) { CineworldUk::Cinema }

  describe '.all' do
    subject { described_class.all }

    it 'returns an Array of CineworldUK::Cinemas' do
      _(subject).must_be_instance_of(Array)
      subject.each do |value|
        _(value).must_be_instance_of(CineworldUk::Cinema)
      end
    end

    it 'returns the correctly sized array' do
      _(subject.size).must_be :>, 18
    end

    it 'returns the right cinemas' do
      _(subject.find { |cinema| cinema.id == 14 }.name).must_equal 'Brighton'
    end
  end
end

describe CineworldUk::Performance do
  let(:described_class) { CineworldUk::Performance }

  describe '.at(cinema_id)' do
    subject { described_class.at(14, from: Date.today + 1, to: Date.today + 1) }

    it 'returns an array of screenings' do
      _(subject).must_be_instance_of(Array)
      subject.each do |performance|
        _(performance).must_be_instance_of(CineworldUk::Performance)
      end
    end

    it 'returns correct number of screenings' do
      _(subject.count).must_be :>, 10
    end
  end
end
