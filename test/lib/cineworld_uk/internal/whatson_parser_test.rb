require_relative '../../../test_helper'

describe CineworldUk::Internal::WhatsonParser do
  let(:described_class) { CineworldUk::Internal::WhatsonParser }

  let(:website) { Minitest::Mock.new }

  before do
    WebMock.disable_net_connect!
  end

  describe '#films_with_screenings' do
    subject { described_class.new(3).films_with_screenings }

    before do
      website.expect(:whatson, brighton_whatson_html, [3])
    end

    it 'returns an non-zero array of film screenings html fragments' do
      CineworldUk::Internal::Website.stub :new, website do
        subject.must_be_instance_of(Array)
        subject.size.must_be :>, 0

        subject.each do |film_html|
          film_html.must_be_instance_of(String)
          film_html.size.must_be :>, 0
        end
      end
    end

    it 'returns an array with correct content' do
      CineworldUk::Internal::Website.stub :new, website do
        # include primary film
        subject.first.must_include('class="span4"') # big poster
        subject.first.must_include('class="span5"') # film info block
        subject.first.must_include('<h3 class="h1">') # title
        subject.first.must_include('class="row day"') # showing rows

        subject[1..-1].each do |html|
          html.must_include('class="span2"') # poster
          html.must_include('class="span7"') # film info block
          html.must_include('<h3 class="h1">') # title
          html.must_include('class="row day"') # showing rows
        end
      end
    end
  end

  private

  def read_file(filepath)
    File.read(File.expand_path(filepath, __FILE__))
  end

  def brighton_whatson_html
    read_file('../../../../fixtures/whatson/brighton.html')
  end
end
