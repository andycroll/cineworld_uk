require_relative '../../test_helper'

class CineworldUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil CineworldUk::VERSION
  end
end
