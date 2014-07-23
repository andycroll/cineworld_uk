require_relative '../../../test_helper'

describe CineworldUk::Internal::Website do
  describe '#cinemas' do
    subject { CineworldUk::Internal::Website.new.cinemas }

    before { stub_get('cinemas', cinemas_html) }

    it 'returns a string' do
      subject.class.must_equal String
    end
  end

  describe '#cinema_information(id)' do
    subject { CineworldUk::Internal::Website.new.cinema_information(3) }

    before { stub_get('cinemas/3/information', information_html) }

    it 'returns a string' do
      subject.class.must_equal String
    end
  end

  describe '#whatson(id)' do
    subject { CineworldUk::Internal::Website.new.whatson(3) }

    before { stub_get('whatson?cinema=3', whatson_html) }

    it 'returns a string' do
      subject.class.must_equal String
    end
  end

  private

  def read_file(filepath)
    File.read(File.expand_path(filepath, __FILE__))
  end

  def cinemas_html
    read_file('../../../../fixtures/cinemas.html')
  end

  def information_html
    read_file('../../../../fixtures/information/brighton.html')
  end

  def stub_get(site_path, response_body)
    url      = "http://www.cineworld.co.uk/#{site_path}"
    response = { status: 200, body: response_body, headers: {} }
    stub_request(:get, url).to_return(response)
  end

  def whatson_html
    read_file('../../../../fixtures/whatson/brighton.html')
  end
end
