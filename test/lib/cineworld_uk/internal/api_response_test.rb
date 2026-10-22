# frozen_string_literal: true

require_relative "../../../test_helper"

class CineworldUk::Internal::ApiResponseTest < Minitest::Test
  include Support::VistaFixtures

  def setup
    setup_vista
  end

  def teardown
    teardown_vista
    super
  end

  def test_rejects_missing_token
    CineworldUk.token = nil

    assert_raises(CineworldUk::AuthenticationError) { CineworldUk::Cinema.all }
  end

  def test_rejects_token_without_exposing_it
    CineworldUk.token = "expired-secret"
    stub_request(:get, "#{BASE_URL}sites").to_return(status: 401, body: "expired-secret")

    error = assert_raises(CineworldUk::AuthenticationError) { CineworldUk::Cinema.all }

    refute_includes error.message, "expired-secret"
  end

  def test_uses_replacement_token
    CineworldUk.token = "replacement"
    stub_request(:get, "#{BASE_URL}sites")
      .with(headers: { "Authorization" => "Bearer replacement" })
      .to_return(body: '{"sites":[]}')

    assert_equal [], CineworldUk::Cinema.all
  end

  def test_does_not_follow_redirects_or_hide_forbidden_responses
    [302, 403].each do |status|
      reset_caches
      stub_request(:get, "#{BASE_URL}sites")
        .to_return(status: status, headers: { "Location" => "https://example.com/" })

      error = assert_raises(RuntimeError) { CineworldUk::Cinema.all }

      assert_includes error.message, status.to_s
    end
  end
end
