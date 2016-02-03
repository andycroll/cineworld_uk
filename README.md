# CineworldUk

A simple gem to parse the [Cineworld UK](http://cineworld.co.uk) cinema times (using their iOS API) and spit out useful formatted info.

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

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

Performance titles are sanitized as much as possible, removing 'screening type' information and 'dimension' as well as standardising all the theatre/cultural event naming (NT Live, Royal Opera House etc).

### Cinema

``` ruby
CineworldUk::Cinema.all
#=> [<CineworldUK::Cinema ...>, <CineworldUK::Cinema ...>, ...]

cinema = CineworldUk::Cinema.new(3)
#=> <CineworldUK::Cinema ...>

cinema.adr
#=> {
  street_address:   'Brighton Marina Village',
  extended_address: nil,
  locality:         'Brighton',
  region:           nil,
  postal_code:      'BN2 5UF',
  country:          'United Kingdom'
}

cinema.brand
#=> 'Cineworld'

cinema.full_name
#=> 'Cineworld Brighton'

cinema.id
#=> '3'

cinema.postal_code
#=> 'BN2 5UF'
```

### Performances

``` ruby
CineworldUk::Performance.at(3)
#=> [<CineworldUK::Performance ...>, <CineworldUK::Performance ...>, ...]

performance = CineworldUk::Performance.at(3).first
#=> <CineworldUK::Performance ...>

performance.film_name
#=> 'Star Wars: The Force Awakens'

performance.dimension
#=> '2d'

performance.variant
#=> ['imax', 'kids']

performance.starting_at
#=> 2016-02-04 13:00:20 UTC

performance.showing_on
#=> #<Date: 2016-02-04 ((2457423j,0s,0n),+0s,2299161j)>

performance.booking_url
#=> "http://www.cineworld.co.uk/booking?performance=..."

performance.cinema_name
#=> 'Brighton'

performance.cinema_id
#=> 3
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
