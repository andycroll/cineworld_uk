require_relative '../../../test_helper'

describe CineworldUk::Internal::FilmWithScreeningsParser do

  describe '#film_name' do
    subject { CineworldUk::Internal::FilmWithScreeningsParser.new(film_html).film_name }

    describe 'passed valid film html with simple name' do
      let(:film_html) { read_film_html('brighton/gravity') }

      it 'returns the film name' do
        subject.must_equal('Gravity')
      end
    end
  end

  describe '#showings' do
    subject { CineworldUk::Internal::FilmWithScreeningsParser.new(film_html).showings }

    describe 'passed valid film html in headline position' do
      let(:film_html) { read_film_html('brighton/gravity') }

      it 'returns a hash keyed by type of performance' do
        subject.must_be_instance_of Hash
        subject.keys.each { |key| key.must_be_instance_of String }
      end

      it 'returns an array of Times for each type of performance' do
        subject.each do |key, value|
          value.must_be_instance_of Array
          value.each do |array|
            array.must_be_instance_of Array
            array[0].must_be_instance_of Time
            array[1].must_be_instance_of String
          end
        end
      end

      it 'returns the correct number of Times' do
        subject.keys.must_equal ['2D', '3D']
        subject['2D'].count.must_equal 49
        subject['3D'].count.must_equal 89
      end

      it 'returns Times in UTC' do
        subject['2D'].first[0].must_equal Time.utc(2013, 11, 13, 12, 0, 0)
        subject['2D'].last[0].must_equal Time.utc(2013, 11, 21, 20, 30, 0)

        subject['3D'].first[0].must_equal Time.utc(2013, 11, 13, 12, 50, 0)
        subject['3D'].last[0].must_equal Time.utc(2013, 11, 21, 17, 45, 0)
      end

      it 'returns booking urls' do
        subject['2D'].first[1].must_equal 'http://www.cineworld.co.uk/booking?cinema=3&filmEdi=39755&date=20131113&time=12:00'
        subject['2D'].last[1].must_equal 'http://www.cineworld.co.uk/booking?cinema=3&filmEdi=43483&date=20131121&time=20:30'

        subject['3D'].first[1].must_equal 'http://www.cineworld.co.uk/booking?cinema=3&filmEdi=39755&date=20131113&time=12:50'
        subject['3D'].last[1].must_equal 'http://www.cineworld.co.uk/booking?cinema=3&filmEdi=43483&date=20131121&time=17:45'
      end
    end

    describe 'passed valid film html in headline position with crazy screens' do
      let(:film_html) { read_film_html('the-o2-greenwich/gravity') }

      it 'returns the correct number of Times' do
        subject.keys.sort.must_equal ['2D', '3D', '3D D-BOX']
        subject['2D'].count.must_equal 5
        subject['3D'].count.must_equal 24
        subject['3D D-BOX'].count.must_equal 19
      end

      it 'returns Times in UTC' do
        subject['2D'].first[0].must_equal Time.utc(2013, 11, 18, 15, 30, 0)
        subject['2D'].last[0].must_equal Time.utc(2013, 11, 21, 18, 35, 0)

        subject['3D'].first[0].must_equal Time.utc(2013, 11, 16, 22, 15, 0)
        subject['3D'].last[0].must_equal Time.utc(2013, 11, 21, 21, 0, 0)

        subject['3D D-BOX'].first[0].must_equal Time.utc(2013, 11, 17, 11, 30, 0)
        subject['3D D-BOX'].last[0].must_equal Time.utc(2013, 11, 20, 19, 0, 0)
      end
    end

    describe 'passed valid film html in headline position with 2d imax' do
      let(:film_html) { read_film_html('glasgow-imax-at-gsc/the-hunger-games-catching-fire') }

      it 'returns the correct number of Times' do
        subject.keys.sort.must_equal ['2D IMAX']
        subject['2D IMAX'].count.must_equal 27
      end

      it 'returns Times in UTC' do
        subject['2D IMAX'].first[0].must_equal Time.utc(2013, 11, 20, 00, 30, 0)
        subject['2D IMAX'].last[0].must_equal Time.utc(2013, 11, 28, 20, 40, 0)
      end
    end

    describe 'passed valid film html with H(obbity)FR' do
      let(:film_html) { read_film_html('the-o2-greenwich/the-hobbit-desolation-of-smaug') }

      it 'returns the correct number of Times' do
        subject.keys.sort.must_equal ['2D', '3D D-BOX', '3D HFR']
        subject['2D'].count.must_equal 26
        subject['3D HFR'].count.must_equal 1
        subject['3D D-BOX'].count.must_equal 23
      end

      it 'returns Times in UTC' do
        subject['2D'].first[0].must_equal Time.utc(2014, 1, 2, 16, 20, 0)
        subject['2D'].last[0].must_equal Time.utc(2014, 1, 9, 19, 20, 0)

        subject['3D HFR'].first[0].must_equal Time.utc(2014, 1, 2, 19, 20, 0)
        subject['3D HFR'].last[0].must_equal Time.utc(2014, 1, 2, 19, 20, 0)

        subject['3D D-BOX'].first[0].must_equal Time.utc(2014, 1, 2, 17, 0, 0)
        subject['3D D-BOX'].last[0].must_equal Time.utc(2014, 1, 9, 20, 20, 0)
      end
    end

  end

  private

  def read_film_html(filename)
    File.read(File.expand_path("../../../../fixtures/whatson/#{filename}.html", __FILE__))
  end
end
