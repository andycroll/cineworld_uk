#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib/cineworld_uk'
  t.test_files = FileList[
    'test/lib/cineworld_uk/*_test.rb',
    'test/lib/cineworld_uk/internal/*_test.rb'
  ]
  t.verbose = true
end

task :default => :test
