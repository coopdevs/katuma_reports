class VariantUnit
  def initialize(variant_unit, variant_unit_scale)
    @variant_unit = variant_unit
    @variant_unit_scale = variant_unit_scale
  end

  def to_s
    if variant_unit == 'weight'
      case variant_unit_scale
      when 1
        'g'
      when 1000
        'kg'
      when 1_000_000
        'T'
      end
    else
      case variant_unit_scale
      when 0.001
        'mL'
      when 1
        'L'
      when 1000
        'kL'
      end
    end
  end

  private

  attr_reader :variant_unit_scale, :variant_unit
end
