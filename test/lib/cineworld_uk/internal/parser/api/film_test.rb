require_relative '../../../../../test_helper'

class CineworldUk::Internal::Parser::Api::FilmTest < Minitest::Test
  def test_id
    assert_equal '014-1001', film.id
  end

  def test_dimension_defaults_to_2d
    assert_equal '2d', film.dimension
  end

  def test_dimension_2d
    assert_equal '2d', film('attributeIds' => ['2d']).dimension
  end

  def test_dimension_3d
    assert_equal '3d', film('attributeIds' => ['3d']).dimension
  end

  def test_dimension_imax_without_3d
    assert_equal '2d', film('attributeIds' => %w(imax 2d)).dimension
  end

  def test_dimension_imax_with_3d
    assert_equal '3d', film('attributeIds' => %w(imax 3d)).dimension
  end

  def test_name
    assert_equal 'Test Film Name', film('name' => 'Test Film Name').name
  end

  def test_name_is_sanitized
    assert_equal 'Royal Opera House: Something', film('name' => 'ROH: Something').name
  end

  def test_name_drops_festival_prefix
    assert_equal 'Scum Of The Earth', film('name' => 'Cine-Excess 2026: Scum Of The Earth').name
  end

  def test_festival
    festival = film('name' => 'Cine-Excess 2026: Scum Of The Earth').festival(2026)

    assert_equal Cinebase::Festival.new(name: 'Cine-Excess', year: 2026), festival
  end

  def test_festival_without_prefix
    assert_nil film.festival(2026)
  end

  def test_variant_is_sorted
    variant = film('attributeIds' => %w(qa junior imax)).variant

    assert_equal variant.sort, variant
  end

  def test_variant_junior_is_kids
    assert_includes film('attributeIds' => ['junior']).variant, 'kids'
  end

  def test_variant_imax
    assert_includes film('attributeIds' => %w(imax 3d)).variant, 'imax'
  end

  def test_variant_unlimited_screening_is_members
    assert_includes film('attributeIds' => ['unlimited-screening']).variant, 'members'
  end

  def test_variant_q_and_a
    assert_includes film('attributeIds' => ['qa']).variant, 'q&a'
  end

  def test_variant_combination
    assert_equal %w(imax members), film('attributeIds' => %w(imax unlimited-screening)).variant
  end

  private

  def film(overrides = {})
    data = { 'id' => '014-1001', 'name' => 'The Example Film', 'attributeIds' => [] }
    CineworldUk::Internal::Parser::Api::Film.new(data.merge(overrides))
  end
end
