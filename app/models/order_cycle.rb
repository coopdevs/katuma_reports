class OrderCycle < ActiveRecord::Base
  belongs_to :coordinator, class_name: 'Enterprise'

  has_many :coordinator_fee_refs, class_name: 'CoordinatorFee'
  has_many :coordinator_fees, through: :coordinator_fee_refs, source: :enterprise_fee
  has_many :exchanges, dependent: :destroy
end
