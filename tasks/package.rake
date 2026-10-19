# frozen_string_literal: true

require "digest"
require "fileutils"
require "rubygems/package"
require "tmpdir"
require "zlib"

namespace :package do
  # SHA-256 digests from the upstream v2.2.3 release assets.
  releases = {
    "x86_64-linux-gnu" => ["x86_64-linux-gnu", "ca7c8aae49e33260d3a2400db16c7737aaf04692d606a843502056b42990f989"],
    "aarch64-linux-gnu" => ["aarch64-linux-gnu", "5e71795b971f32be8f3d7785895f4dceb232f04414f5a067db266432a5b08657"],
    "arm64-darwin" => ["arm64-macos", "2569f4139460fcb301484d37938de91b1c220efd15487ee22a9db554262062fe"],
    "x86_64-darwin" => ["x86_64-macos", "4686806d59abea93866a917c3025a049ef3d7a3240de742ad66bd1a4d9890dc7"]
  }

  desc "Build a gem with bundled curl-impersonate 2.2.3 for the given platform"
  task :native, [:platform] do |_task, args|
    platform = args.fetch(:platform)
    target, digest = releases.fetch(platform)
    root = File.expand_path("..", __dir__)
    asset = "curl-impersonate-v2.2.3.#{target}.tar.gz"
    url = "https://github.com/lexiforest/curl-impersonate/releases/download/v2.2.3/#{asset}"
    archive = File.join(root, "pkg", "downloads", asset)
    FileUtils.mkdir_p(File.dirname(archive))
    unless File.exist?(archive)
      sh "curl", "--fail", "--location", "--retry", "3", "--output", archive, url
    end
    abort "SHA-256 mismatch for #{archive}; delete it and retry" unless Digest::SHA256.file(archive).hexdigest == digest

    spec = Gem::Specification.load(File.join(root, "cineworld_uk.gemspec")).dup
    Dir.mktmpdir("cineworld-package") do |stage|
      spec.files.each do |file|
        destination = File.join(stage, file)
        FileUtils.mkdir_p(File.dirname(destination))
        FileUtils.cp(File.join(root, file), destination)
      end

      vendor = File.join(stage, "vendor", "curl-impersonate")
      Zlib::GzipReader.open(archive) do |gzip|
        Gem::Package::TarReader.new(gzip) do |tar|
          tar.each do |entry|
            next unless entry.file?

            name = entry.full_name
            relative = if name == "curl-impersonate"
                         "bin/curl-impersonate"
                       elsif name.start_with?("LICENSE") && File.basename(name) == name
                         "licenses/#{name}"
                       end
            next unless relative

            destination = File.join(vendor, relative)
            FileUtils.mkdir_p(File.dirname(destination))
            File.binwrite(destination, entry.read)
          end
        end
      end
      File.chmod(0o755, File.join(vendor, "bin", "curl-impersonate"))
      File.write(File.join(vendor, "SOURCE"), <<~SOURCE)
        curl-impersonate 2.2.3
        Binary: #{url}
        SHA-256: #{digest}
        Source and build instructions: https://github.com/lexiforest/curl-impersonate/tree/v2.2.3
        Redistribution notices: licenses/
      SOURCE

      Dir.chdir(stage) do
        spec.platform = Gem::Platform.new(platform)
        spec.files += Dir.glob("vendor/**/*").select { |file| File.file?(file) }
        Gem::Package.build(spec, false, false, File.join(root, "pkg", spec.file_name))
      end
    end
  end

  desc "Build all supported platform gems with bundled curl-impersonate"
  task :all do
    releases.each_key do |platform|
      Rake::Task["package:native"].reenable
      Rake::Task["package:native"].invoke(platform)
    end
  end
end
