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

    describe 'passed valid film html with take 2 name prefix' do
      let(:film_html) { read_film_html('brighton/take-2-thursday-about-time') }

      it 'returns the film name' do
        subject.must_equal('About Time')
      end
    end

    describe 'passed valid film html with autism friendly name prefix' do
      let(:film_html) { read_film_html('brighton/autism-friendly-cloudy-2') }

      it 'returns the film name' do
        subject.must_equal('Cloudy With A Chance Of Meatballs 2')
      end
    end

    describe 'passed valid film html with malayalam language suffix' do
      let(:film_html) { read_film_html('brighton/geethanjali-malayalam') }

      it 'returns the film name' do
        subject.must_equal('Geethanjali')
      end
    end

    describe 'passed valid film html with tamil language suffix' do
      let(:film_html) { read_film_html('wandsworth/arrambam-tamil') }

      it 'returns the film name' do
        subject.must_equal('Arrambam')
      end
    end

    describe 'passed valid film html with bolshoi live' do
      let(:film_html) { read_film_html('wandsworth/bolshoi-ballet-live-lost-illusions') }

      it 'returns the film name' do
        subject.must_equal('Bolshoi: Lost Illusions')
      end
    end

    describe 'passed valid film html with NT 50th encore' do
      let(:film_html) { read_film_html('wandsworth/frankenstein-nt-50th') }

      it 'returns the film name' do
        subject.must_equal('National Theatre: Frankenstein (with Jonny Lee Miller as the Creature)')
      end
    end

    describe 'passed valid film html with met opera and date' do
      let(:film_html) { read_film_html('wandsworth/met-opera-falstaff') }

      it 'returns the film name' do
        subject.must_equal('Met Opera: Falstaff')
      end
    end

    describe 'passed valid film html with nt live' do
      let(:film_html) { read_film_html('wandsworth/nt-live-war-horse') }

      it 'returns the film name' do
        subject.must_equal('National Theatre: War Horse')
      end
    end

    describe 'passed valid film html with ballet live' do
      let(:film_html) { read_film_html('wandsworth/royal-ballet-live-the-sleeping-beauty') }

      it 'returns the film name' do
        subject.must_equal('Royal Ballet: The Sleeping Beauty')
      end
    end

    describe 'passed valid film html with royal opera house and weird date' do
      let(:film_html) { read_film_html('wandsworth/royal-opera-live-parsifal-weird-date') }

      it 'returns the film name' do
        subject.must_equal('Royal Opera House: Parsifal')
      end
    end

    describe 'passed valid film html with RSC and encore' do
      let(:film_html) { read_film_html('wandsworth/rsc-live-richard-ii-encore') }

      it 'returns the film name' do
        subject.must_equal('Royal Shakespeare Company: Richard II')
      end
    end

    describe 'passed valid film html with West End Theatre' do
      let(:film_html) { read_film_html('wandsworth/west-end-theatre-series-private-lives') }

      it 'returns the film name' do
        subject.must_equal("West End Theatre Series: Noel Coward's Private Lives")
      end
    end
  end

  private

  def read_film_html(filename)
    File.read(File.expand_path("../../../../fixtures/whatson/#{filename}.html", __FILE__))
  end
end
