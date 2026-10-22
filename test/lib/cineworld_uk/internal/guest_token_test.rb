# frozen_string_literal: true

require_relative "../../../test_helper"
require "base64"
require "tmpdir"

class CineworldUk::Internal::GuestTokenTest < Minitest::Test
  def setup
    @directory = Dir.mktmpdir("cineworld token ")
    @curl = File.join(@directory, "curl-impersonate")
    CineworldUk.token = "existing-token"
  end

  def teardown
    FileUtils.remove_entry(@directory)
    CineworldUk.token = nil
  end

  def test_sets_and_returns_token_from_200_or_404_page
    html, token = token_page(Time.now.to_i + 3600)

    [200, 404].each do |status|
      serve_token_page(html, status: status)

      assert_equal token, CineworldUk.acquire_token!(curl: @curl)
      assert_equal token, CineworldUk.token
    end
  end

  def test_rejects_expired_tokens_including_boundary_and_keeps_current_token
    now = Time.at(1_800_000_000)
    Time.stub(:now, now) do
      [-1, 0, 1].each do |offset|
        html, token = token_page(now.to_i + offset)
        serve_token_page(html)
        if offset.positive?
          assert_equal token, CineworldUk.acquire_token!(curl: @curl)
        else
          assert_raises(CineworldUk::AuthenticationError) { CineworldUk.acquire_token!(curl: @curl) }
          assert_equal "existing-token", CineworldUk.token
        end
      end
    end
  end

  def test_reports_bad_pages_without_exposing_the_response
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
      assert_equal "existing-token", CineworldUk.token
    end
  end

  def test_reports_missing_executable_or_curl_failure
    error = assert_raises(CineworldUk::AuthenticationError) { CineworldUk.acquire_token!(curl: @curl) }
    assert_includes error.message, "Install curl-impersonate"

    serve_token_page("", status: 0, exit_code: 28)
    error = assert_raises(CineworldUk::AuthenticationError) { CineworldUk.acquire_token!(curl: @curl) }
    assert_includes error.message, "curl exit 28"
  end

  private

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
end
