require_relative '../../../test_helper'

describe CineworldUk::Internal::NameParser do

  describe '#standardize' do
    subject { CineworldUk::Internal::NameParser.new(film_name).standardize }

    [
      ['Rita, Sue and Bob Too', 'Rita, Sue and Bob Too', 'words with "and"'],
      ['Rita, Sue & Bob Too', 'Rita, Sue and Bob Too', 'words with "&"'],
      ['Rita, Sue &amp; Bob Too', 'Rita, Sue and Bob Too', 'words with HTML "&"'],
      ['Cowboys and Aliens', 'Cowboys & Aliens', '"and" as the last but one word'],
      ['Cowboys &amp; Aliens', 'Cowboys & Aliens', 'HTML "&" as the last but one word'],
      ['star wars: episode IV - A new hope', 'Star Wars: Episode IV - A New Hope', 'titleize'],
      ['star wars: episode v - the empire strikes back', 'Star Wars: Episode V - The Empire Strikes Back', 'titleize'],
      ['2 fast 2 furious', '2 Fast 2 Furious', 'titleize'],
      ['Geethanjali (Malayalam)', 'Geethanjali', 'Indian language removal'],
      ['Arrambam (Tamil)', 'Arrambam', 'Indian language removal'],
      ['Take 2 Thursday - About Time', 'About Time', 'remove "Take 2" prefix'],
      ['Autism Friendly Screening: Cloudy With A Chance Of Meatballs 2', 'Cloudy With a Chance of Meatballs 2', 'autism friendly'],
      ['Bolshoi Ballet Live - Lost Illusions', 'Bolshoi: Lost Illusions', 'bolshoi'],
      ['NT Live: War Horse', 'National Theatre: War Horse', 'NT'],
      ['Frankenstein (with Jonny Lee Miller as the Creature) - NT 50th Anniversary encore', 'National Theatre: Frankenstein (With Jonny Lee Miller as the Creature)', 'NT 50th'],
      ['MET Opera - Falstaff - 14/12/2013', 'Met Opera: Falstaff', 'Met Opera with date'],
      ['Royal Ballet Live: The Sleeping Beauty - 19/03/14', 'Royal Ballet: The Sleeping Beauty', 'royal ballet'],
      ['Royal Opera Live: Parsifal - Wednesday 18 Dec 2013', 'Royal Opera House: Parsifal', 'royal opera'],
      ['RSC Live: Richard II (Encore Performance)', 'Royal Shakespeare Company: Richard II', 'rsc'],
      ["West End Theatre Series: Noel Coward's Private Lives", "West End: Noel Coward's Private Lives", 'west end'],
      ["Raiders of\n the Lost Ark", 'Raiders of the Lost Ark', 'New lines']

    ].each do |test_case|

      describe test_case[2] do
        let(:film_name) { test_case[0] }
        it 'returns standardized title' do
          subject.must_equal test_case[1]
        end
      end

    end
  end
end
