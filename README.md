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

Acquire a guest JWT explicitly before retrieving data:

```ruby
require 'cineworld_uk'

CineworldUk.acquire_token!
CineworldUk::Cinema.all
```

This shells out to **`curl-impersonate`**, not ordinary system `curl`, using its
Chrome 150 TLS/HTTP profile. No Python, Chrome, JavaScript execution or browser
cookies are needed. Platform-specific gem packages include the pinned
`curl-impersonate` 2.2.3 executable and its upstream licence notices. RubyGems
and Bundler automatically select the matching package for:

- glibc Linux: x86-64 and ARM64 (`x86_64-linux-gnu`, `aarch64-linux-gnu`)
- macOS: Intel and Apple Silicon (`x86_64-darwin`, `arm64-darwin`)

The executable runs directly from the installed gem. There are no separate
installation commands, PATH changes, or runtime downloads on these platforms.

When installing from Git, forcing the source (`ruby`) gem, or using another
platform (including Alpine/musl and Windows), install a compatible
[curl-impersonate release](https://github.com/lexiforest/curl-impersonate/releases/tag/v2.2.3)
with `--impersonate chrome150` support yourself. For an x86-64 Linux checkout:

```sh
mkdir -p "$HOME/.local/bin"
curl -fL https://github.com/lexiforest/curl-impersonate/releases/download/v2.2.3/curl-impersonate-v2.2.3.x86_64-linux-gnu.tar.gz \
  | tar -xz -C "$HOME/.local/bin" curl-impersonate
export PATH="$HOME/.local/bin:$PATH"
```

Other platforms have separate assets on the release page. You can also specify
the executable path:

```ruby
CineworldUk.acquire_token!(curl: '/opt/curl-impersonate/curl-impersonate')
```

The method returns the token and sets `CineworldUk.token` in memory. It reads
`__NEXT_DATA__.props.pageProps.environment.gasToken` from the ticketing site's
root page, even when the page displays a 404. It checks the declared expiry,
but decoding the JWT does not verify its signature. A blocked page, expired or
missing token, missing executable, or failed command raises
`CineworldUk::AuthenticationError` and leaves any previous token unchanged.
Requests time out after 30 seconds. Certificate verification remains enabled;
redirects are not followed, and subprocess arguments are passed without a shell.
Cloudflare may still block requests on other networks or after website changes.

Alternatively, supply your own current guest JWT without the `Bearer ` prefix;
this requires no external executable:

```ruby
CineworldUk.token = ENV.fetch('CINEWORLD_TOKEN')
```

The gem sends `Authorization: Bearer ...` and `Connect-Region-Code: GB` to
`digital-api.cineworld.co.uk`. Normal API calls never acquire or renew a token
automatically.

Missing tokens and HTTP 401 responses raise `CineworldUk::AuthenticationError`.
Call `CineworldUk.acquire_token!` again, or set `CineworldUk.token` with a fresh
token, before retrying. Tokens are never persisted by the gem. Other HTTP
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

performance.film_year
#=> 1996 # from the title, nil when it has no year

performance.language
#=> 'Tamil' # audio language, nil when the cinema does not tag one

performance.subtitled?
#=> true

performance.festival
#=> #<data Cinebase::Festival name="Cine-Excess", year=2026> # nil outside festivals

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

## Tests

```sh
bundle exec rake          # unit tests against fixtures
bundle exec rake live     # live API, needs curl-impersonate or CINEWORLD_TOKEN
```

Fixtures in `test/fixtures/api` are hand-written: invented films and
addresses in the shape of Vista responses, never recorded API output.
`test/support/api_shapes.rb` describes the fields the gem reads. The unit suite
checks the fixtures against it and the live suite checks real responses, held
only in memory. When the API changes, update the shape first, then the fixtures.

## Building release packages

```sh
bundle exec rake build         # Portable source gem; external curl-impersonate required
bundle exec rake package:all   # Four platform gems with bundled executables
```

To build and check just one platform on a matching host:

```sh
bundle exec rake 'package:native[x86_64-linux-gnu]'
CINEWORLD_PACKAGE=pkg/cineworld_uk-4.3.2-x86_64-linux-gnu.gem bundle exec ruby test/package_test.rb
```

Native packaging downloads pinned upstream archives at **build time**, verifies
their SHA-256 digests, and includes the executable, licence files and source
provenance. Archives and built gems stay in ignored `pkg/`, not Git. CI builds
and installation-tests each platform on its corresponding runner and saves the
gems as workflow artifacts; it does not publish them. Publish the source and
platform gems together for automatic platform selection to work for users.

To release, bump the version, merge, then run the **Release Gem** workflow in
GitHub Actions. It builds the source and four platform gems, publishes them
through RubyGems trusted publishing (no MFA code needed) and tags the release.
Versions already on RubyGems are skipped, so a failed run can be rerun.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Note that contributors assign all rights to the owner, Andy Croll ([github](http://github.com/andycroll)), of this gem.
