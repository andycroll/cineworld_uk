require File.expand_path('../../lib/cineworld_uk.rb', __FILE__)

def fixture(name)
  File.expand_path("../fixtures/#{name}.html", __FILE__)
end

File.open(fixture('cinemas'), 'w') do |file|
  puts '* Cinemas'
  file.write CineworldUk::Internal::Website.new.cinemas
end

# BRIGHTON

File.open(fixture('information/brighton'), 'w') do |file|
  puts '* Brighton Information'
  file.write CineworldUk::Internal::Website.new.cinema_information(3)
end

File.open(fixture('whatson/brighton'), 'w') do |file|
  puts '* Brighton Whats On'
  file.write CineworldUk::Internal::Website.new.whatson(3)
end

parser = CineworldUk::Internal::WhatsonParser.new(3)

File.open(fixture('whatson/brighton/film_first'), 'w') do |file|
  puts '* Brighton Main Film'
  file.write parser.films_with_screenings[0]
end

File.open(fixture('whatson/brighton/film_second'), 'w') do |file|
  puts '* Brighton Second Film'
  file.write parser.films_with_screenings[1]
end

File.open(fixture('whatson/brighton/film_last'), 'w') do |file|
  puts '* Brighton Last Film'
  file.write parser.films_with_screenings[-1]
end

# BRISTOL

File.open(fixture('information/bristol'), 'w') do |file|
  puts '* Bristol Information'
  file.write CineworldUk::Internal::Website.new.cinema_information(4)
end

# O2

parser = CineworldUk::Internal::WhatsonParser.new(79)

File.open(fixture('whatson/the-o2-greenwich/film_first'), 'w') do |file|
  puts '* The O2 Greenwich Main Film'
  file.write parser.films_with_screenings[0]
end

# GLASGOW IMAX

parser = CineworldUk::Internal::WhatsonParser.new(88)

File.open(fixture('whatson/glasgow-imax-at-gsc/film_first'), 'w') do |file|
  puts '* Glasgow IMAX Main Film'
  file.write parser.films_with_screenings[0]
end
