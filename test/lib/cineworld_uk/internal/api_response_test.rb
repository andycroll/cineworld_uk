# frozen_string_literal: true

require_relative "../../../test_helper"
require "tmpdir"

# This block groups independent Minitest cases, not application logic.
describe "Vista retrieval" do # rubocop:disable Metrics/BlockLength
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

describe "Guest token acquisition" do
  before do
    @directory = Dir.mktmpdir("cineworld token ")
    @curl = File.join(@directory, "curl-impersonate")
    CineworldUk.token = "existing-token"
  end

  after do
    FileUtils.remove_entry(@directory)
    CineworldUk.token = nil
  end

  def serve_token_page(html, status: 200, exit_code: 0)
    output = "#{html}\n#{status}"
    File.write(@curl, "#!#{RbConfig.ruby}\nSTDOUT.write(#{output.dump})\nexit #{exit_code}\n")
    File.chmod(0o700, @curl)
  end

  def token_page(expires)
    payload = Base64.urlsafe_encode64(JSON.generate("exp" => expires), padding: false)
    token = "header.#{payload}.signature"
    data = { "props" => { "pageProps" => { "environment" => { "gasToken" => token } } } }
    ["<script type='application/json' id='__NEXT_DATA__'>#{JSON.generate(data)}</script>", token]
  end

  it "sets and returns the guest JWT from either a 200 or 404 page" do
    html, token = token_page(Time.now.to_i + 3600)
    [200, 404].each do |status|
      serve_token_page(html, status: status)
      _(CineworldUk.acquire_token!(curl: @curl)).must_equal token
      _(CineworldUk.token).must_equal token
    end
  end

  it "rejects expired tokens including the expiry boundary without replacing the current token" do
    now = Time.at(1_800_000_000)
    Time.stub(:now, now) do
      [-1, 0, 1].each do |offset|
        html, token = token_page(now.to_i + offset)
        serve_token_page(html)
        if offset.positive?
          _(CineworldUk.acquire_token!(curl: @curl)).must_equal token
        else
          assert_raises(CineworldUk::AuthenticationError) { CineworldUk.acquire_token!(curl: @curl) }
          _(CineworldUk.token).must_equal "existing-token"
        end
      end
    end
  end

  it "reports blocked, redirected, missing and malformed page data without exposing the response" do
    html, token = token_page(Time.now.to_i + 3600)
    invalid_payload = Base64.urlsafe_encode64("broken-secret", padding: false)
    [[html, 403], [html, 302], ["Cloudflare block", 200],
     ["<script id='__NEXT_DATA__'>{</script>", 200],
     ["<script id='__NEXT_DATA__'>{}</script>", 200],
     [html.sub(token, "broken-secret"), 200],
     [html.sub(token, "header.#{invalid_payload}.signature"), 200]].each do |body, status|
      serve_token_page(body, status: status)
      error = assert_raises(CineworldUk::AuthenticationError) { CineworldUk.acquire_token!(curl: @curl) }
      refute_includes error.full_message, token
      refute_includes error.full_message, "broken-secret"
      _(CineworldUk.token).must_equal "existing-token"
    end
  end

  it "reports a missing executable or curl failure as an authentication error" do
    error = assert_raises(CineworldUk::AuthenticationError) { CineworldUk.acquire_token!(curl: @curl) }
    assert_includes error.message, "Install curl-impersonate"
    serve_token_page("", status: 0, exit_code: 28)
    error = assert_raises(CineworldUk::AuthenticationError) { CineworldUk.acquire_token!(curl: @curl) }
    assert_includes error.message, "curl exit 28"
  end
end
