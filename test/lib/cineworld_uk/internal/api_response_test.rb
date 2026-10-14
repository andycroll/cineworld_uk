# frozen_string_literal: true
require_relative "../../../test_helper"

describe "Vista retrieval" do
  before do
    CineworldUk.token = "test-guest-token"
    [CineworldUk::Cinema, CineworldUk::Performance].each do |klass|
      klass.instance_variables.each do |name|
        klass.remove_instance_variable(name)
      end
    end
    fixture = "../../../fixtures/api/vista-showtimes-brighton.json"
    @capture = JSON.parse(File.read(File.expand_path(fixture, __dir__)))
    @base = "https://digital-api.cineworld.co.uk/ocapi/v1/"
    sites = @capture.fetch("relatedData").fetch("sites")
    stub_request(:get, @base + "sites").with(
      headers: {
        "Authorization" => "Bearer test-guest-token",
        "Connect-Region-Code" => "GB"
      }
    ).to_return(body: JSON.generate("sites" => sites))
  end

  after do
    CineworldUk.token = nil
    [CineworldUk::Cinema, CineworldUk::Performance].each do |klass|
      klass.instance_variables.each do |name|
        klass.remove_instance_variable(name)
      end
    end
  end

  def stub_day(day, body)
    stub_request(:get, @base + "showtimes/by-business-date/#{day}").with(
      query: { "siteIds" => "014" },
      headers: { "Authorization" => "Bearer test-guest-token",
                 "Connect-Region-Code" => "GB" }
    ).to_return(body: JSON.generate(body))
  end

  it "retrieves cinemas and advertised session times from Vista" do
    stub_day("2026-10-14", @capture)
    cinema = CineworldUk::Cinema.all.first
    _(cinema.id).must_equal 14
    _(cinema.name).must_equal "Brighton"
    _(cinema.postal_code).must_equal "BN2 5UF"
    _(cinema.street_address).must_equal "Brighton Marina Village"
    assert_requested :get, @base + "sites", times: 1
    performances = CineworldUk::Performance.at(
      14, from: Date.new(2026, 10, 14), to: Date.new(2026, 10, 14)
    )
    _(performances.size).must_equal 17
    first = performances.first
    _(first.film_name).must_equal "Other Mommy"
    _(first.starting_at).must_equal Time.utc(2026, 10, 14, 14, 40)
    _(first.booking_url).must_equal(
      "https://web.cineworld.co.uk/order/showtimes/014-165507/seats"
    )
    _(first.variant).must_include "audio_described"
    _(first.dimension).must_equal "2d"
    assert_requested :get, @base + "sites", times: 1
    assert_requested :get, @base + "showtimes/by-business-date/2026-10-14",
                     query: { "siteIds" => "014" }, times: 1
  end

  it "keeps format session-specific and includes the last requested day" do
    @capture["showtimes"] =
      [@capture["showtimes"].first,
       Marshal.load(Marshal.dump(@capture["showtimes"].first))]
    @capture["showtimes"][1]["id"] = "014-second"
    @capture["showtimes"][1]["requires3dGlasses"] = true
    @capture["showtimes"][1]["schedule"]["startsAt"] =
      "2026-10-25T16:40:00+00:00"
    stub_day("2026-10-24",
             "showtimes" => [],
             "relatedData" => { "films" => [], "attributes" => [],
                                "sites" => [] })
    stub_day("2026-10-25", @capture)
    results = CineworldUk::Performance.at("014", from: Date.new(2026, 10, 24),
                                                 to: Date.new(2026, 10, 25))
    _(results.map(&:dimension)).must_equal %w[2d 3d]
    _(results.last.starting_at).must_equal Time.utc(2026, 10, 25, 16, 40)
    _(results.first.cinema_name).must_equal "Brighton"
    assert_not_requested :get, @base + "sites"
  end

  it "rejects missing and rejected tokens without exposing credentials" do
    CineworldUk.token = nil
    assert_raises(CineworldUk::AuthenticationError) { CineworldUk::Cinema.all }
    CineworldUk.token = "expired-secret"
    stub_request(:get, @base + "sites").to_return(status: 401,
                                                  body: "expired-secret")
    error = assert_raises(CineworldUk::AuthenticationError) do
      CineworldUk::Cinema.all
    end
    refute_includes error.message, "expired-secret"
    CineworldUk.token = "replacement"
    stub_request(:get, @base + "sites").with(
      headers: { "Authorization" => "Bearer replacement" }
    ).to_return(body: '{"sites":[]}')
    _(CineworldUk::Cinema.all).must_equal []
  end

  it "defaults to fourteen days and rejects reversed ranges" do
    day = Date.new(2026, 10, 14)
    (day..day + 13).each do |date|
      stub_day(date.iso8601,
               "showtimes" => [],
               "relatedData" => { "films" => [], "attributes" => [],
                                  "sites" => [] })
    end
    _(CineworldUk::Performance.at(14, from: day)).must_equal []
    assert_requested :get, %r{showtimes/by-business-date/}, times: 14
    assert_raises(ArgumentError) do
      CineworldUk::Performance.at(14, from: day, to: day - 1)
    end
    assert_not_requested :get, @base + "sites"
  end

  it "does not follow redirects or hide forbidden responses" do
    [302, 403].each do |status|
      stub_request(:get, @base + "sites").to_return(
        status: status, headers: { "Location" => "https://example.com/" }
      )
      error = assert_raises(RuntimeError) { CineworldUk::Cinema.all }
      assert_includes error.message, status.to_s
    end
  end
end
