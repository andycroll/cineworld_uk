#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rake/testtask'

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
  t.libs << 'lib/picturehouse_uk'
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

desc 'Recreate test fixtures'
task :fixtures do
  require 'cineworld_uk'

  def js_fixture(name)
    File.expand_path("../test/fixtures/#{name}.json", __FILE__)
  end

  api = CineworldUk::Internal::ApiResponse.new

  File.open(js_fixture('api/cinema-list'), 'w') do |file|
    puts '* API Cinema List'
    file.write api.cinema_list
  end

  File.open(js_fixture('api/cinema-detail-3'), 'w') do |file|
    puts '* API Cinema Detail Brighton'
    file.write api.cinema_detail(3)
  end

  File.open(js_fixture('api/cinema-detail-96'), 'w') do |file|
    puts '* API Cinema Detail Birmingham NEC'
    file.write api.cinema_detail(96)
  end

  File.open(js_fixture('api/cinema-detail-21'), 'w') do |file|
    puts '* API Cinema Detail Edinburgh'
    file.write api.cinema_detail(21)
  end

  File.open(js_fixture('api/cinema-detail-10'), 'w') do |file|
    puts '* API Cinema Detail Chelsea'
    file.write api.cinema_detail(10)
  end

  File.open(js_fixture('api/film-list'), 'w') do |file|
    puts '* API Film List'
    file.write api.film_list
  end

  File.open(js_fixture('api/film-list-comingsoon'), 'w') do |file|
    puts '* API Film List Coming Soon'
    file.write api.film_list_comingsoon
  end

  File.open(js_fixture('api/performances-tomorrow-3'), 'w') do |file|
    puts '* API Performances in Brighton Tomorrow'
    file.write api.performances(3, Date.today + 1)
  end

  File.open(js_fixture('api/dates-3'), 'w') do |file|
    puts '* API Dates Brighton Tomorrow'
    file.write api.dates(3)
  end
end

task :default => :test
