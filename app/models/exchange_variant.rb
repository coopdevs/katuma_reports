class ExchangeVariant < ActiveRecord::Base
  belongs_to :variant, class_name: 'Spree::Variant'
end
