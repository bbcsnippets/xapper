require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "xml-to-ruby-hash-mapper"
  gem.homepage = "http://github.com/bbcsnippets/xml-to-ruby-hash-mapper"
  gem.license = "MIT"
  gem.summary = %Q{A simple mapper that takes an XML and maps it into a ruby hash}
  gem.description = %Q{Give it an xml and define a mapping for it as a ruby hash and there you have it. A ruby hash for your XML}
  gem.email = "dutta.anuj@gmail.com"
  gem.authors = ["andhapp"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :examples do
  $: << "."
  require "examples/book_list"
end

task :default => :spec
