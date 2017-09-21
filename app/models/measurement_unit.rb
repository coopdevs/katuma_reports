# This class replicates the logic contained in OFN's
# app/assets/javascripts/admin/products/services/variant_unit_manager.js.coffee
#
# It goes one step further and by decoupling from variant and product it builds
# and abstraction of a measurement unit. For weight and volume only.
class MeasurementUnit
  CONVERSIONS = {
    weight: {
      1 => 'g',
      1000 => 'kg',
      1_000_000 => 'T'
    },
    volume: {
      0.001 => 'mL',
      1 => 'L',
      1000 => 'kL'
    }
  }.freeze

  def initialize(type, scale)
    @type = type
    @scale = scale
  end

  def to_s
    CONVERSIONS[type.to_sym][scale]
  end

  private

  attr_reader :scale, :type
end
