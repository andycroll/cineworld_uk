## MASTER

Bugfix

- Cineworld changed their markup

Under the hood

- Travis gets Ruby 2.1.2

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
