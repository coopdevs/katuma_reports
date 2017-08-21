class OrderCycle < ActiveRecord::Base
  belongs_to :coordinator, class_name: 'Enterprise'
end
