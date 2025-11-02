require_relative '../../../../../test_helper'
require_relative '../../../../../support/fixture_reader'

describe CineworldUk::Internal::Parser::Api::Film do
  include Support::FixtureReader

  let(:described_class) { CineworldUk::Internal::Parser::Api::Film }
  let(:data) { random_film }

  before { WebMock.disable_net_connect! }
  after { WebMock.allow_net_connect! }

  describe '#id' do
    subject { described_class.new(data).id }

    it 'is a string' do
      subject.must_be_instance_of(String)
    end

    it 'is the film id from the data' do
      subject.must_equal(data['id'])
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

    describe 'attributeIds includes "2d"' do
      let(:data) { random_film.merge('attributeIds' => ['2d']) }

      it 'is 2d' do
        subject.must_equal('2d')
      end
    end

    describe 'attributeIds includes "3d"' do
      let(:data) { random_film.merge('attributeIds' => ['3d']) }

      it 'is 3d' do
        subject.must_equal('3d')
      end
    end

    describe 'attributeIds with imax but not 3d' do
      let(:data) { random_film.merge('attributeIds' => ['imax', '2d']) }

      it 'is 2d' do
        subject.must_equal('2d')
      end
    end

    describe 'attributeIds with imax and 3d' do
      let(:data) { random_film.merge('attributeIds' => ['imax', '3d']) }

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

    describe 'film name' do
      let(:data) do
        random_film.merge('name' => 'Test Film Name')
      end

      it 'is the film name' do
        subject.must_equal('Test Film Name')
      end
    end

    describe 'film name is unsanitized' do
      let(:data) { random_film.merge('name' => 'ROH: Something') }

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

    describe 'attributeIds includes "junior"' do
      let(:data) do
        random_film.merge('attributeIds' => ['junior'])
      end

      it 'includes "kids"' do
        subject.must_include('kids')
      end
    end

    describe 'attributeIds includes "imax"' do
      let(:data) do
        random_film.merge('attributeIds' => ['imax', '3d'])
      end

      it 'includes "imax"' do
        subject.must_include('imax')
      end
    end

    describe 'attributeIds includes "unlimited-screening"' do
      let(:data) do
        random_film.merge('attributeIds' => ['unlimited-screening'])
      end

      it 'includes "members"' do
        subject.must_include('members')
      end
    end

    describe 'attributeIds includes "qa"' do
      let(:data) do
        random_film.merge('attributeIds' => ['qa'])
      end

      it 'includes "q&a"' do
        subject.must_include('q&a')
      end
    end

    describe 'combination' do
      let(:data) do
        random_film.merge('attributeIds' => ['imax', 'unlimited-screening'])
      end

      it 'includes "members"' do
        subject.must_include('imax', 'members')
      end
    end
  end

  private

  def random_film
    JSON.parse(performances_tomorrow_json(14))['body']['films'].sample
  end
end
