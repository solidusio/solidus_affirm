VCR.configure do |config|
  config.ignore_localhost = true
  config.cassette_library_dir = "spec/fixtures/vcr_casettes"
  config.hook_into :webmock
end
