require 'rspec'
require 'fedex'
require 'support/vcr'
require 'support/credentials'

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.filter_run_excluding :production unless fedex_production_credentials
end

