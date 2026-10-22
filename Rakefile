#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rake/testtask'
require 'cinebase/vista/package_task'

Cinebase::Vista::PackageTask.new('cineworld_uk.gemspec', root: __dir__)

Rake::TestTask.new do |t|
  t.libs << 'lib/cineworld_uk'
  t.test_files = FileList[
    'test/lib/cineworld_uk/*_test.rb',
    'test/lib/cineworld_uk/internal/*_test.rb',
    'test/lib/cineworld_uk/internal/parser/api/*_test.rb'
  ]
  t.verbose = true
end

Rake::TestTask.new do |t|
  t.libs << 'lib/cineworld_uk'
  t.name = :live
  t.test_files = FileList[
    'test/live/*_test.rb'
  ]
  t.verbose = true
end

desc 'console'
# http://erniemiller.org/2014/02/05/7-lines-every-gems-rakefile-should-have/
task :console do
  require 'irb'
  require 'irb/completion'
  require 'cineworld_uk'
  ARGV.clear
  IRB.start
end

task :default => :test
