require_relative '../../../../../test_helper'

class CineworldUk::Internal::Parser::Api::CinemaAddressTest < Minitest::Test
  CINEMAS = [
    {
      'id' => '014', 'displayName' => 'Brighton',
      'addressInfo' => { 'address1' => '1 Example Marina', 'city' => 'Brighton',
                         'postalCode' => 'BN2 0ZZ' }
    },
    {
      'id' => '090', 'displayName' => 'Birmingham Example',
      'addressInfo' => { 'address1' => '2 Example Resort', 'address2' => 'Example Way',
                         'city' => 'Birmingham', 'postalCode' => 'B40 0ZZ' }
    },
    {
      'id' => '037', 'displayName' => 'Edinburgh Example',
      'addressInfo' => { 'address1' => '3 Example Park', 'address3' => '4 Example Street',
                         'city' => 'Edinburgh', 'postalCode' => 'EH11 0ZZ' }
    },
    {
      'id' => '103', 'displayName' => 'London - Leicester Square',
      'addressInfo' => { 'address1' => '5 Example Square', 'address2' => 'Example Row',
                         'city' => 'London', 'postalCode' => 'WC2H 0ZZ' }
    }
  ].freeze

  def test_one_line_address
    assert_address 14, street_address: '1 Example Marina', extended_address: nil,
                       locality: 'Brighton', region: nil, postal_code: 'BN2 0ZZ'
  end

  def test_second_line_is_extended_address
    assert_address 90, street_address: '2 Example Resort', extended_address: 'Example Way',
                       locality: 'Birmingham', region: nil, postal_code: 'B40 0ZZ'
  end

  def test_third_line_is_extended_address_without_second
    assert_address 37, street_address: '3 Example Park', extended_address: '4 Example Street',
                       locality: 'Edinburgh', region: nil, postal_code: 'EH11 0ZZ'
  end

  def test_london_has_region_and_no_extended_address
    assert_address 103, street_address: '5 Example Square', extended_address: nil,
                        locality: 'London', region: 'London', postal_code: 'WC2H 0ZZ'
  end

  private

  def assert_address(id, expected)
    assert_equal expected.merge(country: 'United Kingdom'),
                 CineworldUk::Internal::Parser::Api::CinemaAddress.new(id, CINEMAS).to_hash
  end
end
