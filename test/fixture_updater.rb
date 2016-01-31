require File.expand_path('../../lib/cineworld_uk.rb', __FILE__)

def js_fixture(name)
  File.expand_path("../fixtures/#{name}.json", __FILE__)
end

# def fixture(name)
#   File.expand_path("../fixtures/#{name}.html", __FILE__)
# end

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
