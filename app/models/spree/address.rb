module Spree
  class Address < ActiveRecord::Base
    self.table_name = 'spree_addresses'

    belongs_to :country, class_name: "Spree::Country"
    belongs_to :state, class_name: "Spree::State"
  end
end
