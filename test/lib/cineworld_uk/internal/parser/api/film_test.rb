require_relative '../../../../../test_helper'
require_relative '../../../../../support/fixture_reader'

describe CineworldUk::Internal::Parser::Api::Film do
  include Support::FixtureReader

  let(:described_class) { CineworldUk::Internal::Parser::Api::Film }
  let(:data) { random_film }

  describe '#id' do
    subject { described_class.new(data).id }

    it 'is an integer' do
      subject.must_be_instance_of(Fixnum)
    end

    it 'is the film id from the data' do
      subject.must_equal(data['edi'])
    end
  end

  describe '#dimension' do
    subject { described_class.new(data).dimension }

    it 'is a string' do
      subject.must_be_instance_of(String)
    end

    it 'is 2d or 3d' do
      subject.must_match(/[23]d/)
    end

    describe 'hash["format"] is "2D"' do
      let(:data) { random_film.merge('format' => '2D') }

      it 'is 2d' do
        subject.must_equal('2d')
      end
    end

    describe 'hash["format"] is "3D"' do
      let(:data) { random_film.merge('format' => '3D') }

      it 'is 3d' do
        subject.must_equal('3d')
      end
    end

    describe 'hash["format"] is "IMAX"' do
      let(:data) { random_film.merge('format' => 'IMAX') }

      it 'is 2d' do
        subject.must_equal('2d')
      end
    end

    describe 'hash["format"] is "IMAX3D"' do
      let(:data) { random_film.merge('format' => 'IMAX3D') }

      it 'is 3d' do
        subject.must_equal('3d')
      end
    end
  end

  describe '#name' do
    subject { described_class.new(data).name }

    it 'is a string' do
      subject.must_be_instance_of(String)
    end

    describe 'hash["originalTitle"] is different' do
      let(:data) do
        random_film.merge('originalTitle' => 'Original Title',
                          'title' => 'Title')
      end

      it 'is the original title' do
        subject.must_equal('Original Title')
      end
    end

    describe 'original title is unsanitized' do
      let(:data) { random_film.merge('originalTitle' => 'ROH: Something') }

      it 'is sanitized' do
        subject.must_equal('Royal Opera House: Something')
      end
    end
  end

  describe '#variant' do
    subject { described_class.new(data).variant }

    it 'is a sorted array of strings' do
      subject.must_be_instance_of(Array)
      subject.each { |element| element.must_be_instance_of(String) }
      subject.sort.must_equal(subject)
    end

    describe 'hash["title"] includes "Movies For Juniors"' do
      let(:data) do
        random_film.merge('title' => 'Movies For Juniors - Something')
      end

      it 'includes "kids"' do
        subject.must_include('kids')
      end
    end

    describe 'hash["format"] is "IMAX3D"' do
      let(:data) do
        random_film.merge('title' => 'nothing', 'format' => 'IMAX3D')
      end

      it 'includes "imax"' do
        subject.must_include('imax')
      end
    end

    describe 'hash["format"] is "IMAX"' do
      let(:data) do
        random_film.merge('format' => 'IMAX')
      end

      it 'includes "imax"' do
        subject.must_include('imax')
      end
    end

    describe 'hash["title"] includes "Unlimited Screening"' do
      let(:data) do
        random_film.merge('title' => 'Something Unlimited Screening')
      end

      it 'includes "members"' do
        subject.must_include('members')
      end
    end

    describe 'hash["title"] includes "with Live Q And A"' do
      let(:data) do
        random_film.merge('title' => 'Something With Live Q And A')
      end

      it 'includes "q&a"' do
        subject.must_include('q&a')
      end
    end

    describe 'combination' do
      let(:data) do
        random_film.merge('format' => 'IMAX',
                          'title' => 'Something Unlimited Screening')
      end

      it 'includes "members"' do
        subject.must_include('imax', 'members')
      end
    end
  end

  private

  def random_film
    JSON.parse(film_list_json)['films'].sample
  end
end
