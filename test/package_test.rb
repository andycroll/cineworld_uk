# Run separately after building: CINEWORLD_PACKAGE=pkg/...gem bundle exec ruby test/package_test.rb
require "minitest/autorun"
require "rubygems/installer"
require "tmpdir"
require "fileutils"
require "open3"
require "base64"
require "json"

describe "Platform package" do
  before do
    @directory = Dir.mktmpdir("cineworld-package-test")
    @spec = Gem::Installer.at(
      ENV.fetch("CINEWORLD_PACKAGE"), install_dir: @directory, ignore_dependencies: true
    ).install
    @vendor = File.join(@spec.full_gem_path, "vendor", "curl-impersonate")
    @binary = File.join(@vendor, "bin", "curl-impersonate")
  end

  after do
    FileUtils.remove_entry(@directory)
  end

  it "installs a runnable executable with upstream notices and provenance" do
    assert File.executable?(@binary)
    output, status = Open3.capture2(@binary, "--version")
    assert status.success?
    assert_includes output, "curl"
    assert File.file?(File.join(@vendor, "licenses", "LICENSE_CURL"))
    assert_includes File.read(File.join(@vendor, "SOURCE")), "2.2.3"
  end

  it "acquires a token using the gem-local executable without any curl on PATH" do
    payload = Base64.urlsafe_encode64(JSON.generate("exp" => Time.now.to_i + 3600), padding: false)
    token = "header.#{payload}.signature"
    data = { "props" => { "pageProps" => { "environment" => { "gasToken" => token } } } }
    page = "<script id='__NEXT_DATA__'>#{JSON.generate(data)}</script>\n200"
    # Substitute only the network response, not the installed package's path resolution.
    File.write(@binary, "#!#{RbConfig.ruby}\nSTDOUT.write(#{page.dump})\n")
    output, error, status = Open3.capture3(
      { "PATH" => @directory, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil,
        "GEM_PATH" => Gem.path.join(File::PATH_SEPARATOR) }, RbConfig.ruby,
      "-I#{File.join(@spec.full_gem_path, 'lib')}", "-rcineworld_uk",
      "-e", "print CineworldUk.acquire_token!"
    )
    assert status.success?, error
    _(output).must_equal token
  end
end
