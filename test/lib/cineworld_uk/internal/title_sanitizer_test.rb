require_relative '../../../test_helper'

class CineworldUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_removes_2d
    assert_sanitized 'Iron Man 3', 'Iron Man 3 2D'
  end

  def test_removes_3d
    assert_sanitized 'Iron Man 3', 'Iron Man 3 3d'
  end

  def test_removes_language
    assert_sanitized 'Bang Bang!', 'Bang Bang! (Hindi)'
    assert_sanitized 'Deadline', 'Deadline (Mandarin)'
  end

  def test_removes_dub_version
    assert_sanitized 'Kung Fu Soccer', 'Kung Fu Soccer (Dubbed)'
  end

  def test_removes_unlimited_screening
    assert_sanitized 'Nightcrawler', 'Nightcrawler - Unlimited Screening'
  end

  def test_removes_autism_prefix
    assert_sanitized 'Dolphin Tale 2', 'Autism Friendly Screening: Dolphin Tale 2'
  end

  def test_keeps_bolshoi_ballet
    assert_sanitized 'Bolshoi Ballet: The Legend of Love', 'Bolshoi Ballet: The Legend of Love'
  end

  def test_eno
    assert_sanitized 'English National Opera: La Traviata', 'ENO: La Traviata '
  end

  def test_removes_imax_prefix
    assert_sanitized 'Fury', '(IMAX) Fury'
  end

  def test_met_opera
    assert_sanitized 'Met Opera: Le Nozze Di Figaro', 'MET Opera - Le Nozze Di Figaro'
  end

  def test_nt_live_encore
    assert_sanitized 'National Theatre: Frankenstein (starring Benedict Cumberbatch)',
                     'NT Live Encore: Frankenstein (starring Benedict Cumberbatch)'
  end

  def test_nt_live
    assert_sanitized 'National Theatre: Treasure Island', 'NT Live: Treasure Island'
  end

  def test_nt_live_with_encore_suffix
    assert_sanitized 'National Theatre: A Streetcar Named Desire (Young Vic)',
                     'NT Live: A Streetcar Named Desire (Young Vic) - Encore'
  end

  def test_roh
    assert_sanitized 'Royal Opera House: I Due Foscari', 'ROH - I Due Foscari'
  end

  def test_rbo_season
    assert_sanitized 'Royal Ballet and Opera: Manon', 'RBO Cinema Season 2026-27: Manon'
  end

  def test_rsc
    assert_sanitized "Royal Shakespeare Company: Love's Labour's Lost",
                     "RSC Live: Love's Labour's Lost"
  end

  def test_removes_sciscreen
    assert_sanitized 'Dallas Buyers Club', 'SciScreen: Dallas Buyers Club'
  end

  def test_removes_special_performance
    assert_sanitized 'Billy Elliot The Musical Live',
                     'Billy Elliot The Musical Live - Special Performance'
  end

  def test_removes_take_2
    assert_sanitized 'Boyhood', 'Take 2 - Boyhood'
  end

  def test_removes_singalong_and_movies_for_juniors
    assert_sanitized 'Frozen', 'Frozen Sing-Along - Movies For Juniors'
  end

  def test_keeps_sing_along_within_title
    assert_sanitized 'Bebefinn Sing-Along Movie', 'Bebefinn Sing-Along Movie'
  end

  def test_removes_format_prefix
    assert_sanitized 'Wildwood', '(4DX) Wildwood'
    assert_sanitized 'Wildwood', '(ScreenX) Wildwood'
  end

  def test_removes_movies_for_juniors_prefix
    assert_sanitized 'Paw Patrol: The Mighty Movie', 'M4J: Paw Patrol: The Mighty Movie'
  end

  def test_removes_family_films_prefix
    assert_sanitized 'Paw Patrol: The Dino Movie', '£2 Family Films : Paw Patrol: The Dino Movie'
  end

  def test_removes_film_year
    assert_sanitized 'Street Fighter', 'Street Fighter (2026)'
  end

  def test_removes_season_prefix_and_year
    assert_sanitized 'From Dusk Till Dawn', 'Horror Season 2026 From Dusk Till Dawn (1996)'
  end

  def test_removes_re_release
    assert_sanitized 'Zindagi Na Milegi Dobara', 'Zindagi Na Milegi Dobara (Re-release) (Hindi)'
  end

  def test_removes_festival_prefix
    assert_sanitized 'Scum Of The Earth', 'Cine-Excess 2026: Scum Of The Earth'
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, CineworldUk::Internal::TitleSanitizer.new(title).sanitized
  end
end
