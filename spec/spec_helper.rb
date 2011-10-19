$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'bundler'
Bundler.require
require 'xml_to_ruby_hash_mapper'

RSpec.configure do |config|
end
