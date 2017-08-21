module Spree
  class State < ActiveRecord::Base
    self.table_name = 'spree_states'

    belongs_to :country, class_name: 'Spree::Country'
  end
end
