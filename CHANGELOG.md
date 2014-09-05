## 2.0.3 _5th September 2014_

Bugfix

- fix the Website class and use `open-uri`

## 2.0.2 _25th July 2014_

Bugfix

- bad behaviour for screening#variant

## 2.0.1 _25th July 2014_

Bugfix

- httparty still required, oops

## 2.0.0 _25th July 2014_

Bugfix

- Cineworld changed their markup

Features

- Less logic in the Cinema class. Moved to `Film` and `Screening`.
- Introduce `Internal::Website` class for all website comms
- Rewrite Parsers and tests to be less exact but less fragile
- Screening now uses the `FilmWithScreeningsParser`
- Build `WhatsonParser` to break into 'films with screenings'
- `FilmWithScreenings` then uses `ScreeningParser` class to get individual screening info
- `ruby test/fixture_updator.rb` produces new fixtures from the live website
  - it will break a few tests when run and committed but most should be ok
- documentation

Under the hood

- Remove dependancy on HTTParty
- Travis gets Ruby 2.1.2
- General Rubocop improvements

## 1.0.6 _28th Feb 2014_

Bugfix

- UTF encoding in Titleize internal class for ruby 1.9.3

## 1.0.5 _28th Feb 2014_

Bugfix

- Vestigal require of titleize gem

## 1.0.4 _27th Feb 2014_

Under the hood

- Standardizing film names using modified titlecase from `titlecase` gem
- Film name parsing now moved to seperate class
- rake console task added
- MRI 2.1.0 support on Travis CI

## 1.0.3, _16th Jan 2014_

Additional methods

- cinema#full_name including cinema brand
- tidy up cinema naming to use colons

## 1.0.2, _3rd Jan 2014_

Under the hood

- deal with HFR screenings, bloody hobbitses

## 1.0.1, _3rd Jan 2014_

External interface

- screening#variant for spelling win, #varient maintained for compatability

## 1.0.0, _6th Dec 2013_

First ready-for-public release

- Added changelog
- added booking url to screenings
- screenings created with UTC Time objects not strings
- added cinema addresses
- Get films and screenings out of a cinema
