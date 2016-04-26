# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## HEAD

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
