# CineworldUk

A gem to retrieve [Cineworld UK](https://www.cineworld.co.uk) cinemas and showtimes using the Vista API.

[![Gem Version](https://badge.fury.io/rb/cineworld_uk.svg)](https://badge.fury.io/rb/cineworld_uk)
[![Tests](https://github.com/andycroll/cineworld_uk/actions/workflows/.travis.yml/badge.svg)](https://github.com/andycroll/cineworld_uk/actions)

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

### Authentication

Configure a current guest JWT before retrieving data (without the `Bearer ` prefix):

```ruby
require 'cineworld_uk'

CineworldUk.token = ENV.fetch('CINEWORLD_TOKEN')
```

The gem sends `Authorization: Bearer ...` and `Connect-Region-Code: GB` to
`digital-api.cineworld.co.uk`. It does not acquire or refresh tokens, copy browser
cookies, or bypass Cloudflare. The ticketing website supplies its guest token in
`__NEXT_DATA__.props.pageProps.environment.gasToken`; access to that page may
require an interactive browser.

Missing tokens and HTTP 401 responses raise `CineworldUk::AuthenticationError`.
Set `CineworldUk.token` again with a fresh token before retrying. Other HTTP
failures raise an error rather than returning an empty schedule. Redirects are
not followed, so credentials are not forwarded to another host.

There is no verified fixed token lifetime. Its declared lifetime is `exp - iat`
seconds. The website reloads to renew after 90% of that interval. To inspect
your token locally without printing it (decoding does not verify its signature):

```ruby
require 'base64'
payload = CineworldUk.token.split('.').fetch(1)
claims = JSON.parse(Base64.urlsafe_decode64(payload))
puts "Lifetime: #{claims.fetch('exp') - claims.fetch('iat')} seconds"
puts "Expires: #{Time.at(claims.fetch('exp')).utc}"
```

### Cinema

``` ruby
CineworldUk::Cinema.all
#=> [<CineworldUK::Cinema ...>, <CineworldUK::Cinema ...>, ...]

cinema = CineworldUk::Cinema.new(14)
#=> <CineworldUK::Cinema ...>

cinema.adr
#=> {
  street_address:   'Brighton Marina Village',
  extended_address: nil,
  locality:         'Brighton',
  region:           'East Sussex',
  postal_code:      'BN2 5UF',
  country:          'United Kingdom'
}

cinema.brand
#=> 'Cineworld'

cinema.full_name
#=> 'Cineworld Brighton'

cinema.id
#=> 14

cinema.postal_code
#=> 'BN2 5UF'
```

### Performances

`at` accepts a numeric Vista cinema ID (`14`, `'14'` or `'014'` for Brighton),
not a Boxoffice ID such as `X079B`. Dates are inclusive **business dates**.
Without dates, it fetches today in London and the following 13 days; it does not
discover every future screening date.

```ruby
day = Date.new(2026, 10, 14)
performances = CineworldUk::Performance.at(14, from: day, to: day)
```

This makes **one HTTP request per cinema per requested day**, including empty
days. Cinema names, film titles and attributes come from the same response—no
extra cinema or film lookups are needed. `Cinema.all` separately fetches and
caches the cinema list in memory, shared by name and address lookups. Performance
responses are not cached across calls, so reuse the returned array when possible.

Advertised session times (`startsAt`), not feature start times (`filmStartsAt`),
are converted to UTC using the offsets supplied by Vista. Recognized session
attributes populate the existing dimension and variant fields; unknown attributes
are ignored. No seat-availability or booking operations are performed.

``` ruby
CineworldUk::Performance.at(14)
#=> [<CineworldUK::Performance ...>, <CineworldUK::Performance ...>, ...]

performance = performances.first
#=> <CineworldUK::Performance ...>

performance.film_name
#=> 'Other Mommy'

performance.dimension
#=> '2d'

performance.variant
#=> ['audio_described']

performance.starting_at
#=> 2026-10-14 14:40:00 UTC

performance.showing_on
#=> Date.new(2026, 10, 14)

performance.booking_url
#=> "https://web.cineworld.co.uk/order/showtimes/014-165507/seats"

performance.cinema_name
#=> 'Brighton'

performance.cinema_id
#=> 14
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Note that contributors assign all rights to the owner, Andy Croll ([github](http://github.com/andycroll)), of this gem.
