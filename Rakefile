require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rake/testtask'
require File.expand_path('../lib/mongo_mapper/plugins/version', __FILE__)

Rake::TestTask.new do |t|
  t.libs = %w(test)
  t.pattern = 'test/*_test.rb'
end
  
task :default => :test

desc 'Builds the gem'
task :build do
  sh "gem build mongo_mapper_nested_attributes.gemspec"
end

desc 'Builds and installs the gem'
task :install => :build do
  sh "gem install mongo_mapper_nested_attributes-#{MongoMapper::Plugins::NestedAttributes::Version}"
end

desc 'Tags version, pushes to remote, and pushes gem'
task :release => :build do
  sh "git tag v#{MongoMapper::Plugins::NestedAttributes::Version}"
  sh "git push origin master"
  sh "git push origin v#{MongoMapper::Plugins::NestedAttributes::Version}"
  sh "gem push mongo_mapper_nested_attributes-#{MongoMapper::Plugins::NestedAttributes::Version}.gem"
end
