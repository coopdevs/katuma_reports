Spree::Product.class_eval do
  belongs_to :supplier, class_name: 'Enterprise', touch: true
  belongs_to :primary_taxon, class_name: 'Spree::Taxon'

  after_save :ensure_standard_variant

  scope :for_order_cycle, ->(order_cycle) { where(order_cycles: { id: order_cycle.id }) }

  private

  def ensure_standard_variant
    if master.valid? && variants.empty?
      variant = self.master.dup
      variant.product = self
      variant.is_master = false
      variant.on_demand = self.on_demand
      self.variants << variant
    end
  end
end
