require_relative '../../test_helper'

describe CineworldUk do
  it 'must be defined' do
    _(CineworldUk::VERSION).wont_be_nil
  end
end
