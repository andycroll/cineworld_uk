require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(color: true)
]

require File.expand_path('../../../lib/cineworld_uk.rb', __FILE__)
require_relative '../support/api_shapes'

CineworldUk.token = ENV.fetch('CINEWORLD_TOKEN') { CineworldUk.acquire_token! }
