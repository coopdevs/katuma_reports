# This class replicates the logic contained in OFN's
# app/assets/javascripts/admin/products/services/variant_unit_manager.js.coffee
#
# It goes one step further and by decoupling from variant and product it builds
# and abstraction of a measurement unit. For weight and volume only.
class MeasurementUnit
  class Error < StandardError; end

  CONVERSIONS = {
    'weight' => {
      1.0 => 'g',
      1000.0 => 'kg',
      1_000_000.0 => 'T'
    },
    'volume' => {
      0.001 => 'mL',
      1.0 => 'L',
      1000.0 => 'kL'
    }
  }.freeze

  # Constructor
  #
  # @param type [Symbol]
  # @param scale [Numeric]
  # @param name [String] name of the custom unit
  def initialize(type, scale, name = nil)
    @type = type
    @scale = scale.to_f
    @name = name
  end

  # Returns the appropriate unit name (g, kg, L, mL, etc) for the given type
  # and scale
  #
  # @return [String]
  def to_s
    if type == 'items'
      name
    else
      CONVERSIONS.fetch(type, {}).fetch(scale)
    end
  rescue KeyError
    raise Error, "No conversion for type '#{type}' and scale '#{scale}'"
  end

  private

  attr_reader :scale, :type, :name
end
