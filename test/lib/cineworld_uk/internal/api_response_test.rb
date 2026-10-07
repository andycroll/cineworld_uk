require_relative '../../../test_helper'
require_relative '../../../support/fixture_reader'

describe CineworldUk::Internal::ApiResponse do
  include Support::FixtureReader

  let(:described_class) { CineworldUk::Internal::ApiResponse }
  let(:standard) { 'attr=&lang=en_GB' }
  let(:until_date) { (Date.today + 365).strftime('%Y-%m-%d') }

  before { WebMock.disable_net_connect! }
  after { WebMock.allow_net_connect! }

  describe '#cinema_list' do
    subject { described_class.new.cinema_list }

    before { stub_get("cinemas/with-event/until/#{until_date}?#{standard}", cinema_list_json) }

    it 'returns a string' do
      _(subject.class).must_equal String
    end
  end

  describe '#dates(cinema_id)' do
    subject { described_class.new.dates(14) }

    before { stub_get("dates/in-cinema/014/until/#{until_date}?#{standard}", dates_json(14)) }

    it 'returns a string' do
      _(subject.class).must_equal String
    end
  end

  describe '#performances(cinema_id, date)' do
    subject { described_class.new.performances(14, Date.today + 1) }

    before do
      tomorrow = (Date.today + 1).strftime('%Y-%m-%d')
      stub_get("film-events/in-cinema/014/at-date/#{tomorrow}?#{standard}",
               performances_tomorrow_json(14))
    end

    it 'returns a string' do
      _(subject.class).must_equal String
    end
  end

  private

  def stub_get(site_path, response_body)
    url      = "https://www.cineworld.co.uk/uk/data-api-service/v1/quickbook/10108/#{site_path}"
    response = { status: 200, body: response_body, headers: {} }
    stub_request(:get, url).to_return(response)
  end
end
