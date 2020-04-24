require 'vcr'
require_relative 'credentials'

VCR.configure do |c|
  path = '../../vcr'
  if real_credentials?
    path = '../../vcr-real-requests'
  end
  c.cassette_library_dir  = File.expand_path(path, __FILE__)
  c.hook_into :webmock
end

RSpec.configure do |c|
  c.include Fedex::Helpers
  c.around(:each, :vcr) do |example|
    name = underscorize(example.metadata[:full_description].split(/\s+/, 2).join("/")).gsub(/[^\w\/]+/, "_")
    VCR.use_cassette(name) { example.call }
  end
end
