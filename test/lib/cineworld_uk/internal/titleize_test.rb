require_relative '../../../test_helper'

describe CineworldUk::Internal::Titleize do

  describe '#titleize(name)' do
    subject { CineworldUk::Internal::Titleize.titleize(string) }

    [
      [
        'star wars: episode iv - a new hope',
        'Star Wars: Episode IV - A New Hope'
      ],
      [
        'star wars: episode v - the empire strikes back',
        'Star Wars: Episode V - The Empire Strikes Back'
      ],
      ['2 fast 2 furious', '2 Fast 2 Furious'],
      ['saw iv', 'Saw IV'],
      ['fast & Furious 6', 'Fast & Furious 6'],
      ['fast & Furious vi', 'Fast & Furious VI']
    ].each do |test_case|

      describe test_case[2] do
        let(:string) { test_case[0] }
        it 'returns titlecase' do
          subject.must_equal test_case[1]
        end
      end
    end
  end

  describe '#phrases(name)' do
    subject { CineworldUk::Internal::Titleize.phrases(string) }

    [
      [
        'star wars: episode iv - a new hope',
        ['star wars:', 'episode iv -', 'a new hope']
      ]
    ].each do |test_case|

      describe test_case[0] do
        let(:string) { test_case[0] }
        it 'splits the name' do
          subject.must_equal test_case[1]
        end
      end
    end
  end
end
