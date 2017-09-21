require 'delegate'

class ProductPresenter < SimpleDelegator
  def units
    MeasurementUnit.new(product.variant_unit, product.variant_unit_scale).to_s
  rescue MeasurementUnit::Error
    ''
  end

  private

  def product
    __getobj__
  end
end
