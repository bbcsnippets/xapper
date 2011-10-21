$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'bundler'
Bundler.require
require 'xapper'

RSpec.configure do |config|
end
