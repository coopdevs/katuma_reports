class EnterpriseFee < ActiveRecord::Base
  FEE_TYPES = %w(packing transport admin sales fundraising)

  belongs_to :enterprise
end
