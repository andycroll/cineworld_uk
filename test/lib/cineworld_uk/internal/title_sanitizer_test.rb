require_relative '../../../test_helper'

describe CineworldUk::Internal::TitleSanitizer do
  let(:described_class) { CineworldUk::Internal::TitleSanitizer }

  describe '#sanitized' do
    subject { described_class.new(title).sanitized }

    describe 'with 2d in title' do
      let(:title) { 'Iron Man 3 2D' }

      it 'removes dimension' do
        subject.must_equal('Iron Man 3')
      end
    end

    describe 'with 3d in title' do
      let(:title) { 'Iron Man 3 3d' }

      it 'removes dimension' do
        subject.must_equal('Iron Man 3')
      end
    end

    describe 'in hindi' do
      let(:title) { 'Bang Bang! (Hindi)' }

      it 'removes language' do
        subject.must_equal('Bang Bang!')
      end
    end

    describe 'Unlimited Screening' do
      let(:title) { 'Nightcrawler - Unlimited Screening' }

      it 'removes prefix' do
        subject.must_equal('Nightcrawler')
      end
    end

    describe 'Austism screening' do
      let(:title) { 'Autism Friendly Screening: Dolphin Tale 2' }

      it 'removes prefix' do
        subject.must_equal('Dolphin Tale 2')
      end
    end

    describe 'Bolshoi screening' do
      let(:title) { 'Bolshoi Ballet: The Legend of Love' }

      it 'removes prefix' do
        subject.must_equal('Bolshoi: The Legend of Love')
      end
    end

    describe 'English National Opera screening' do
      let(:title) { 'ENO: La Traviata ' }

      it 'removes prefix' do
        subject.must_equal('English National Opera: La Traviata')
      end
    end

    describe 'with IMAX' do
      let(:title) { '(IMAX) Fury' }

      it 'removes prefix' do
        subject.must_equal('Fury')
      end
    end

    describe 'Met Opera screening' do
      let(:title) { 'MET Opera - Le Nozze Di Figaro' }

      it 'removes prefix' do
        subject.must_equal('Met Opera: Le Nozze Di Figaro')
      end
    end

    describe 'NT Live screening' do
      let(:title) { 'NT Live Encore: Frankenstein (starring Benedict Cumberbatch)' }

      it 'removes prefix' do
        subject.must_equal('National Theatre: Frankenstein (starring Benedict Cumberbatch)')
      end
    end

    describe 'National Theatre screening' do
      let(:title) { 'NT Live: Treasure Island' }

      it 'removes prefix' do
        subject.must_equal('National Theatre: Treasure Island')
      end
    end

    describe 'National Theatre Encore screening' do
      let(:title) { 'NT Live: A Streetcar Named Desire (Young Vic) - Encore' }

      it 'removes prefix' do
        subject.must_equal('National Theatre: A Streetcar Named Desire (Young Vic)')
      end
    end

    describe 'ROH screening' do
      let(:title) { 'ROH - I Due Foscari' }

      it 'removes prefix' do
        subject.must_equal('Royal Opera House: I Due Foscari')
      end
    end

    describe 'RSC screening' do
      let(:title) { "RSC Live: Love's Labour's Lost" }

      it 'removes prefix' do
        subject.must_equal("Royal Shakespeare Company: Love's Labour's Lost")
      end
    end

    describe 'special screening' do
      let(:title) { 'Billy Elliot The Musical Live - Special Performance' }

      it 'removes prefix' do
        subject.must_equal('Billy Elliot The Musical Live')
      end
    end

    describe 'Take 2 screening' do
      let(:title) { 'Take 2 - Boyhood' }

      it 'removes prefix' do
        subject.must_equal('Boyhood')
      end
    end
  end
end
