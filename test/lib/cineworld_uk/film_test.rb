require_relative '../../test_helper'

describe CineworldUk::Film do

  before { WebMock.disable_net_connect! }

  describe '.new(name)' do
    it 'stores name' do
      film = CineworldUk::Film.new 'Iron Man 3'
      film.name.must_equal 'Iron Man 3'
    end
  end

  describe '.at(cinema_id)' do
    let(:website) { Minitest::Mock.new }

    subject { CineworldUk::Film.at(3) }

    before do
      website.expect(:whatson, whatson_html('brighton'), [3])
    end

    it 'returns an array of films' do
      CineworldUk::Internal::Website.stub :new, website do
        subject.must_be_instance_of(Array)
        subject.each do |film|
          film.must_be_instance_of(CineworldUk::Film)
        end
      end
    end

    it 'returns a decent number of films' do
      CineworldUk::Internal::Website.stub :new, website do
        subject.count.must_be :>, 15
      end
    end

    it 'returns uniquely named films' do
      CineworldUk::Internal::Website.stub :new, website do
        subject.each_with_index do |item, index|
          subject.each_with_index do |jtem, i|
            next if index == i
            item.name.wont_equal jtem.name
            item.wont_equal jtem
          end
        end
      end
    end
  end

  describe 'Comparable' do
    it 'includes comparable methods' do
      film = CineworldUk::Film.new 'AAAA'
      film.methods.must_include :<
      film.methods.must_include :>
      film.methods.must_include :==
      film.methods.must_include :<=>
      film.methods.must_include :<=
      film.methods.must_include :>=
    end

    describe 'uniqueness' do
      it 'defines #hash' do
        film = CineworldUk::Film.new 'AAAA'
        film.methods.must_include :hash
      end

      describe '#hash' do
        it 'returns a hash of the slug' do
          film = CineworldUk::Film.new 'AAAA'
          film.hash == film.slug.hash
        end
      end

      it 'defines #eql?(other)' do
        film = CineworldUk::Film.new 'AAAA'
        film.methods.must_include :eql?
      end

      describe 'two identically named films' do
        let(:film)      { CineworldUk::Film.new 'AAAA' }
        let(:otherfilm) { CineworldUk::Film.new 'AAAA' }

        it 'retuns only one' do
          result = [film, otherfilm].uniq
          result.count.must_equal 1
          result.must_equal [ CineworldUk::Film.new('AAAA') ]
        end
      end
    end

    describe '<=> (other)' do
      subject { film <=> otherfilm }

      describe 'film less than other' do
        let(:film)      { CineworldUk::Film.new 'AAAA' }
        let(:otherfilm) { CineworldUk::Film.new 'BBBB' }

        it 'retuns -1' do
          subject.must_equal -1
        end
      end

      describe 'film greater than other' do
        let(:film)      { CineworldUk::Film.new 'CCCC' }
        let(:otherfilm) { CineworldUk::Film.new 'BBBB' }

        it 'retuns 1' do
          subject.must_equal 1
        end
      end

      describe 'film same as other (exact name)' do
        let(:film)      { CineworldUk::Film.new 'AAAA' }
        let(:otherfilm) { CineworldUk::Film.new 'AAAA' }

        it 'retuns 0' do
          subject.must_equal 0
        end
      end

      describe 'film same as other (inexact name)' do
        let(:film)      { CineworldUk::Film.new 'blue jasmine' }
        let(:otherfilm) { CineworldUk::Film.new 'Blue Jasmine' }

        it 'retuns 0' do
          subject.must_equal 0
        end
      end
    end
  end

  private

  def read_file(filepath)
    File.read(File.expand_path(filepath, __FILE__))
  end

  def whatson_html(filename)
    read_file("../../../fixtures/whatson/#{filename}.html")
  end
end
