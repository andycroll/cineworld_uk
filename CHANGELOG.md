# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## 4.4.0 - 2026-10-31

### Added
- `Cinema#latitude` and `Cinema#longitude` as Floats in decimal degrees, from the Vista sites response. They are `nil` when a site has no location or sits at 0, 0.
- `CineworldUk.ensure_token!` fetches a guest token only when there is none or it expires within an hour, and `CineworldUk.token_expires_at` reads its expiry. Both come from cinebase's `Vista::TokenHolder`.

### Changed
- A token the API rejects is cleared from `CineworldUk.token`, so the next `ensure_token!` fetches a fresh one.
- Requires cinebase 5.6.

## 4.3.2 - 2026-10-22

### Changed
- Reuse one Vista client, and so one kept-alive connection, per thread instead of opening a TLS connection for every request. Requires cinebase 5.5. A cinema day now takes about 0.19s rather than 0.37s.

## 4.3.1 - 2026-10-22

### Fixed
- Publish the platform gems that bundle curl-impersonate. 4.3.0 shipped only the source gem. No code changes.

## 4.3.0 - 2026-10-22

### Added
- `Performance#film_year`, read from a trailing `(1996)` in the title, so a re-release gives the original year.
- `4dx` and `screenx` variants from Vista's `4DX`, `4DX 3D` and `ScreenX` attributes.

### Changed
- Require cinebase 5.4. Titles also lose `+ ... Q&A` and `+ Discussion` add-ons, `(35mm)`, `(70mm)` and `4K` markers, and `CFF:` festival prefixes.
- Film titles lose their year suffix and the `(4DX)`, `(ScreenX)`, `M4J:`, `£2 Family Films :`, `Horror Season 2026` and `(Re-release)` markers, and Lithuanian versions. For example `Horror Season 2026 From Dusk Till Dawn (1996)` is now `From Dusk Till Dawn` with `film_year` 1996 and the Horror Season 2026 festival. Consumers matching films by name will see these names change.

## 4.2.0 - 2026-10-22

### Added
- `Performance#language` from Vista language attributes such as `Tamil`, `Performance#subtitled?`, and `Performance#festival`, a `Cinebase::Festival` with `name` and `year`.
- Live API shape tests that check real responses without storing them.

### Changed
- Require cinebase 5.2. The Vista client, guest token retrieval and platform packaging task now come from `cinebase/vista`; behaviour, errors and pinned curl-impersonate digests are unchanged.
- `CineworldUk::AuthenticationError` is now `Cinebase::Vista::AuthenticationError`, so existing `rescue` clauses keep working.
- Film titles also use cinebase's common rules: dub and subtitle versions, more language versions, anniversaries, Q&A add-ons and festival prefixes are removed.
- Tests use plain `Minitest::Test` classes, with hand-written fixtures in place of recorded API responses.

### Fixed
- `Sing-Along` inside a real title, such as `Bebefinn Sing-Along Movie`, is no longer removed.

### Removed
- The `fixtures` rake task, which saved API responses into the repository.

## 4.1.0 - 2026-10-15

### Added
- Explicit guest token acquisition and renewal with `CineworldUk.acquire_token!`, using the standalone `curl-impersonate` CLI without Python or a browser.
- Platform-specific gems bundle curl-impersonate 2.2.3 for x86-64/ARM64 glibc Linux and macOS, with pinned archive checksums, upstream notices, and native package CI checks. No separate executable installation is needed on these platforms.
- Optional executable path for token acquisition. Existing caller-supplied tokens continue to work without the CLI.
- Expiry checks and authentication errors for unavailable commands, blocked pages, and missing or invalid page tokens; failed acquisition preserves the previous token.

## 4.0.0 - 2026-10-15

### Changed
- Retrieve cinemas and performances from the Vista API instead of the retired iOS API.
- Require a caller-supplied guest JWT through `CineworldUk.token`; token acquisition and renewal remain the caller's responsibility.
- `Performance.at` accepts inclusive `from:` and `to:` business dates, defaulting to today in London and the following 13 days rather than discovering all screening dates.
- Use one request per cinema per requested day, reusing related film, cinema and attribute data. Share cached cinema data with address lookups.
- Convert advertised session times to UTC using Vista's explicit offsets and preserve session-specific formats.

### Added
- `CineworldUk::AuthenticationError` for missing tokens and HTTP 401 responses.
- Orb setup for the pinned Ruby version and gem dependencies.

## 3.1.0 - 2016-09-11

### Fixed
- Use of www2 domain, set to HTTPS and www

### Added
- Tests against live server, using `rake live`

## 3.0.4 - 2016-04-26

### Fixed
- Unforgiving use of #fetch in film for API

## 3.0.3 - 2016-02-10

### Changed
- Performance.at uses a Fixnum internally

## 3.0.2 - 2016-02-09

### Added
- private class methods on `Performance` & `Cinema`
- improved documentation

### Changed
- readme badges
- code climate coverage
- non-commercial license is AGPL

## 3.0.1 - 2016-02-03

### Removed
- Removed redundant nokogiri dependency

## 3.0.0 - 2016-02-03

The cinebase standardisation release.

### Removed
- Remove website as data source
- Remove film concept

### Added
- Use iOS api as a data source

### Changed
- Parse cinema address from iOS api
- Screening becomes Performance in cinebase 2.0.0
- Parse performances & films iOS API
- Use the `cinebase` gem to fix an common API across all gems

## 2.1.6 - 2015-05-06

# Fixed
- whats on page is the cinema url

## 2.1.5 - 2015-02-18

# Fixed
- more defensive against closing cinemas

## 2.1.4 - 2015-01-03

### Added
- title sanitation
  - movies for juniors
  - singalong

## 2.1.3 - 2014-12-31

### Fixed
- better title sanitization of:
  - movies for juniors
  - additional languages: Punjabi, Turkish
  - Q&A

## 2.1.2 - 2014-10-20

### Added
- better title sanitization
- ENO -> English National Opera

### Fixed
- typos in the test suite


## 2.1.1 - 2014-09-30

### Fixed
- pilot error


## 2.1.0 2014-09-30

### Added
- Name Sanitization

### Fixed
- Films with no 'link' on the screenings page now parsed


## 2.0.5 2014-09-28

### Fixed
- fix cinema parsing call to website class


## 2.0.4 2014-09-05

### Fixed
- fix the parsing


## 2.0.3 2014-09-05

### Fixed
- fix the Website class and use `open-uri`


## 2.0.2 2014-07-25

### Fixed
- bad behaviour for screening#variant


## 2.0.1 2014-07-25

### Fixed
- httparty still required, oops


## 2.0.0 2014-07-25

### Fixed
- Cineworld changed their markup
- General Rubocop improvements

### Added
- Less logic in the Cinema class. Moved to `Film` and `Screening`.
- Introduce `Internal::Website` class for all website comms
- Rewrite Parsers and tests to be less exact but less fragile
- Screening now uses the `FilmWithScreeningsParser`
- Build `WhatsonParser` to break into 'films with screenings'
- `FilmWithScreenings` then uses `ScreeningParser` class to get individual screening info
- `ruby test/fixture_updator.rb` produces new fixtures from the live website
- documentation
- Travis gets Ruby 2.1.2

### Removed
- Remove dependancy on HTTParty


## 1.0.6 2014-02-28

### Fixed
- UTF encoding in Titleize internal class for ruby 1.9.3


## 1.0.5 2014-02-28

### Fixed
- Vestigal require of titleize gem


## 1.0.4 2014-02-27

### Added
- Standardizing film names using modified titlecase from `titlecase` gem
- Film name parsing now moved to seperate class
- `rake console` task added
- MRI 2.1.0 support on Travis CI


## 1.0.3 2014-01-16

### Added
- cinema#full_name including cinema brand
- tidy up cinema naming to use colons


## 1.0.2 2014-01-03

### Added
- deal with HFR screenings, bloody hobbitses


## 1.0.1 2014-01-03

### Added
- screening#variant for spelling win, #varient maintained for compatability


## 1.0.0 2013-12-06

### Added
- Added changelog
- added booking url to screenings
- screenings created with UTC Time objects not strings
- added cinema addresses
- Get films and screenings out of a cinema
