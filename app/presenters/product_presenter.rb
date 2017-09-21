require 'delegate'

class ProductPresenter < SimpleDelegator
  def units
    VariantUnit.new(product.variant_unit, product.variant_unit_scale)
  end

  private

  def product
    __getobj__
  end
end
