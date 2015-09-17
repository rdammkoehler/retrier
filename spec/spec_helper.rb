require 'retrier'

require 'gimme'

RSpec.configure do |config|
  config.mock_framework = Gimme::RSpecAdapter
end