ENV['MOCK_CORE'] ||= 'true'
ENV['CORE_URL'] ||= "http://api-development.localdev.engineyard.com:9292"

require 'tempfile'

Bundler.require(:default, :test)

Dir[File.expand_path("../{shared,support}/*.rb", __FILE__)].each{|f| require(f)}

require File.expand_path("../../lib/ey-core", __FILE__)

#cli = File.expand_path("../../lib/ey-core/cli.rb", __FILE__)

#require cli
#asdf = Dir[File.expand_path("../../lib/ey-core/cli*/**/*.rb", __FILE__)]
#asdf.each do |f|
  #require f
#end

RSpec.configure do |config|
  config.order = "random"
end
