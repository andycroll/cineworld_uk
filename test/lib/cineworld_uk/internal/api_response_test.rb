require_relative '../../../test_helper'
require_relative '../../../support/fixture_reader'

describe CineworldUk::Internal::ApiResponse do
  include Support::FixtureReader

  let(:described_class) { CineworldUk::Internal::ApiResponse }

  before { WebMock.disable_net_connect! }
  after { WebMock.allow_net_connect! }

  describe '#cinema_list' do
    subject { described_class.new.cinema_list }

    before do
      schema_html = <<~HTML
        <html>
          <head></head>
          <body>
            <script type="application/ld+json">
              {
                "@context": "https://schema.org",
                "@type": "ItemList",
                "numberOfItems": 2,
                "itemListElement": [
                  {
                    "@type": "ListItem",
                    "position": 1,
                    "item": {
                      "@type": "MovieTheater",
                      "name": "Brighton",
                      "url": "https://www.cineworld.co.uk/theaters/x079b-cineworld-cinema-brighton",
                      "address": {"streetAddress": "Marina Village", "addressLocality": "Brighton"},
                      "telephone": "01273123123"
                    }
                  },
                  {
                    "@type": "ListItem",
                    "position": 2,
                    "item": {
                      "@type": "MovieTheater",
                      "name": "Glasgow",
                      "url": "https://www.cineworld.co.uk/theaters/x06tn-cineworld-cinema-glasgow",
                      "address": {"streetAddress": "Quay Street", "addressLocality": "Glasgow"},
                      "telephone": "01413339999"
                    }
                  }
                ]
              }
            </script>
          </body>
        </html>
      HTML
      stub_request(:get, 'https://www.cineworld.co.uk/cinemas/').to_return(
        status: 200,
        body: schema_html
      )
    end

    it 'returns a string' do
      _(subject.class).must_equal String
    end

    it 'contains cinema data' do
      data = JSON.parse(subject)
      _(data).must_be_instance_of Array
      _(data.length).must_equal 2
      _(data.first['name']).must_equal 'Brighton'
    end
  end

  describe '#dates(cinema_id)' do
    subject { described_class.new.dates(14) }

    it 'returns a string' do
      _(subject.class).must_equal String
    end

    it 'returns array of dates' do
      data = JSON.parse(subject)
      _(data).must_be_instance_of Array
      _(data.length).must_be :>, 5
    end
  end

  describe '#performances(cinema_id, date)' do
    subject { described_class.new.performances(14, Date.today + 1) }

    it 'returns a string' do
      _(subject.class).must_equal String
    end

    it 'returns array' do
      data = JSON.parse(subject)
      _(data).must_be_instance_of Array
    end
  end
end
