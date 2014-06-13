# CineworldUk

A simple gem to parse the [Cineworld UK website](http://cineworld.co.uk) and spit out useful formatted info.

[![Gem Version](https://badge.fury.io/rb/cineworld_uk.svg)](http://badge.fury.io/rb/cineworld_uk)
[![Code Climate](https://codeclimate.com/github/andycroll/cineworld_uk.png)](https://codeclimate.com/github/andycroll/cineworld_uk)
[![Build Status](https://travis-ci.org/andycroll/cineworld_uk.png?branch=master)](https://travis-ci.org/andycroll/cineworld_uk)
[![Inline docs](http://inch-ci.org/github/andycroll/cineworld_uk.png)](http://inch-ci.org/github/andycroll/cineworld_uk)

## Installation

Add this line to your application's Gemfile:

    gem 'cineworld_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cineworld_uk

## Usage

### Cinema

``` ruby
CineworldUK::Cinema.all
#=> [<CineworldUK::Cinema brand="Cineworld" name="Duke's At Komedia" slug="dukes-at-komedia" chain_id="Dukes_At_Komedia" url="...">, #=> <CineworldUK::Cinema brand="Cineworld" name="Duke o York's" slug="duke-of-yorks" chain_id="Brighton" url="...">, ...]

CineworldUK::Cinema.find('3')
#=> <CineworldUK::Cinema brand="Cineworld" name="Brighton" slug="duke-of-yorks" address="..." chain_id="Brighton" url="...">

cinema.brand
#=> 'Cineworld'

cinema.id
#=> '3'

cinema.films
#=> [<CineworldUK::Film name="Iron Man 3">, <CineworldUK::Film name="Star Trek: Into Darkness">]

cinema.screenings
#=> [<CineworldUK::Screening film="About Time" when="2013-09-09 11:00 UTC" variant="3d">, <CineworldUK::Screening film="Iron Man 3" when="2013-09-09 13:50 UTC" variant="kids">, <CineworldUK::Screening ..>, <CineworldUK::Screening ...>]

cinema.screenings_of 'Iron Man 3'
#=> [<CineworldUK::Screening film="Iron Man 3" when="2013-09-09 11:00 UTC" variant="3d">, <CineworldUK::Screening film="Iron Man 3" when="2013-09-09 13:50 UTC" variant="kids">]

cinema.screenings_of <CineworldUK::Film name="Iron Man 3">
#=> [<CineworldUK::Screening film="Iron Man 3" when="2013-09-09 11:00 UTC" variant="3d">, <CineworldUK::Screening film="Iron Man 3" when="2013-09-09 13:50 UTC" variant="kids">]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
