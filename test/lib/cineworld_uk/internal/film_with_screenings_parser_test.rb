require_relative '../../../test_helper'

describe CineworldUk::Internal::FilmWithScreeningsParser do
  let(:described_class) { CineworldUk::Internal::FilmWithScreeningsParser }

  describe '#cinema_id' do
    subject { described_class.new(film_html).cinema_id }

    describe 'passed film html from top of page' do
      let(:film_html) { read_film_html('brighton/film_first') }

      it 'returns the id' do
        subject.must_equal(3)
      end
    end

    describe 'passed second html from page' do
      let(:film_html) { read_film_html('brighton/film_second') }

      it 'returns the id' do
        subject.must_equal(3)
      end
    end

    describe 'passed last html from end of page' do
      let(:film_html) { read_film_html('brighton/film_last') }

      it 'returns the id' do
        subject.must_equal(3)
      end
    end
  end

  describe '#film_name' do
    subject { described_class.new(film_html).film_name }

    describe 'passed film html from top of page' do
      let(:film_html) { read_film_html('brighton/film_first') }

      it 'returns the film name' do
        subject.must_be_instance_of(String)
        subject.must_equal('The Boxtrolls')
      end
    end

    describe 'passed film html from page' do
      let(:film_html) { read_film_html('brighton/film_second') }

      it 'returns the film name' do
        subject.must_be_instance_of(String)
        subject.must_equal('Sex Tape')
      end
    end

    describe 'passed film html from end of page' do
      let(:film_html) { read_film_html('brighton/film_last') }

      it 'returns the film name' do
        subject.must_be_instance_of(String)
        subject.must_equal('The Vatican Museums')
      end
    end
  end

  describe '#to_a' do
    subject { described_class.new(film_html).to_a }

    describe 'passed film html from top of page' do
      let(:film_html)       { read_film_html('brighton/film_first') }
      let(:permitted_types) { %w(baby hfr kids) }

      it 'returns a non-zero array of hashes' do
        subject.must_be_instance_of(Array)
        subject.size.must_be :>=, 1
        subject.each do |hash|
          hash.must_be_instance_of(Hash)
        end
      end

      it 'contains properly completed hashes' do
        subject.each do |hash|
          hash[:booking_url].must_include('http://www.cineworld.co.uk')
          hash[:dimension].must_match(/\A[23]d\z/)
          hash[:time].must_be_instance_of(Time)
          hash[:variant].must_be_instance_of(Array)
          hash[:variant].each do |type|
            type.must_be_instance_of(String)
            permitted_types.must_include(type)
          end
        end
      end
    end

    describe 'passed film html from top of dbox cinema page' do
      let(:film_html)       { read_film_html('the-o2-greenwich/film_first') }
      let(:permitted_types) { %w(baby dbox hfr kids) }

      it 'returns a hash with allowed variants' do
        subject.each do |hash|
          hash[:variant].each do |type|
            type.must_be_instance_of(String)
            permitted_types.must_include(type)
          end
        end
      end
    end

    describe 'passed film html from top of imax cinema page' do
      let(:film_html)       { read_film_html('glasgow-imax-at-gsc/film_first') }
      let(:permitted_types) { %w(baby dbox hfr imax kids) }

      it 'returns a hash with allowed variants' do
        subject.each do |hash|
          hash[:variant].each do |type|
            type.must_be_instance_of(String)
            permitted_types.must_include(type)
          end
        end
      end
    end
  end

  private

  def read_film_html(filename)
    path = '../../../../fixtures/whatson/'
    File.read(File.expand_path(path + "#{filename}.html", __FILE__))
  end
end
