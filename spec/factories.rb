require 'ffaker'
require 'spree/core/testing_support/factories'

FactoryGirl.define do
  factory :enterprise, class: Enterprise do
    owner { FactoryGirl.create :user }
    sequence(:name) { |n| "Enterprise #{n}" }
    sells 'any'
    description 'enterprise'
    long_description '<p>Hello, world!</p><p>This is a paragraph.</p>'
    email 'enterprise@example.com'
    address { FactoryGirl.create(:address) }
    confirmed_at { Time.zone.now }
    sequence(:permalink) { |n| "permalink#{n}" }
  end

  factory :distributor_enterprise, :parent => :enterprise do
    is_primary_producer false
    sells "any"

    ignore do
      with_payment_and_shipping false
    end

    after(:create) do |enterprise, proxy|
      if proxy.with_payment_and_shipping
        create(:payment_method,  distributors: [enterprise])
        create(:shipping_method, distributors: [enterprise])
      end
    end
  end

  factory :simple_order_cycle, :class => OrderCycle do
    sequence(:name) { |n| "Order Cycle #{n}" }

    orders_open_at  { 1.day.ago }
    orders_close_at { 1.week.from_now }

    coordinator { Enterprise.is_distributor.first || FactoryGirl.create(:distributor_enterprise) }

    ignore do
      suppliers []
      distributors []
      variants []
    end

    after(:create) do |oc, proxy|
      proxy.suppliers.each do |supplier|
        ex = create(:exchange, :order_cycle => oc, :sender => supplier, :receiver => oc.coordinator, :incoming => true, :receival_instructions => 'instructions')
        proxy.variants.each { |v| ex.variants << v }
      end

      proxy.distributors.each do |distributor|
        ex = create(:exchange, :order_cycle => oc, :sender => oc.coordinator, :receiver => distributor, :incoming => false, :pickup_time => 'time', :pickup_instructions => 'instructions')
        proxy.variants.each { |v| ex.variants << v }
      end
    end
  end

  factory :order_cycle, parent: :simple_order_cycle do
    coordinator_fees { [create(:enterprise_fee, enterprise: coordinator)] }

    after(:create) do |oc|
      # Suppliers
      supplier1 = create(:supplier_enterprise)
      supplier2 = create(:supplier_enterprise)

      # Incoming Exchanges
      ex1 = create(:exchange, :order_cycle => oc, :incoming => true,
                   :sender => supplier1, :receiver => oc.coordinator,
                   :receival_instructions => 'instructions 0')
      ex2 = create(:exchange, :order_cycle => oc, :incoming => true,
                   :sender => supplier2, :receiver => oc.coordinator,
                   :receival_instructions => 'instructions 1')

      enterprise_fee = create(:enterprise_fee, enterprise: ex1.sender)
      ExchangeFee.create!(exchange: ex1, enterprise_fee: enterprise_fee)
      ExchangeFee.create!(exchange: ex2,
                          enterprise_fee: create(:enterprise_fee, enterprise: ex2.sender))

      # Distributors
      distributor1 = create(:distributor_enterprise)
      distributor2 = create(:distributor_enterprise)

      # Outgoing Exchanges
      ex3 = create(:exchange, :order_cycle => oc, :incoming => false,
                   :sender => oc.coordinator, :receiver => distributor1,
                   :pickup_time => 'time 0', :pickup_instructions => 'instructions 0')
      ex4 = create(:exchange, :order_cycle => oc, :incoming => false,
                   :sender => oc.coordinator, :receiver => distributor2,
                   :pickup_time => 'time 1', :pickup_instructions => 'instructions 1')
      ExchangeFee.create!(exchange: ex3,
                          enterprise_fee: create(:enterprise_fee, enterprise: ex3.receiver))
      ExchangeFee.create!(exchange: ex4,
                          enterprise_fee: create(:enterprise_fee, enterprise: ex4.receiver))

      [ex1, ex2].each do |exchange|
        product = create(:product, supplier: exchange.sender)
        exchange.variants << product.variants.first
      end

      variants = [ex1, ex2].map(&:variants).flatten
      [ex3, ex4].each do |exchange|
        variants.each { |v| exchange.variants << v }
      end
    end
  end

  factory :enterprise_fee, class: EnterpriseFee do
    ignore { amount nil }

    sequence(:name) { |n| "Enterprise fee #{n}" }
    sequence(:fee_type) { |n| EnterpriseFee::FEE_TYPES[n % EnterpriseFee::FEE_TYPES.count] }

    enterprise { Enterprise.first || FactoryGirl.create(:supplier_enterprise) }
    calculator { build(:calculator_per_item, preferred_amount: amount) }

    after(:create) { |ef| ef.calculator.save! }
  end

  factory :calculator_per_item, class: Spree::Calculator::PerItem do
    preferred_amount { generate(:calculator_amount) }
  end

  factory :supplier_enterprise, parent: :enterprise do
    is_primary_producer true
    sells "none"
  end

  factory :exchange, class: Exchange do
    incoming    false
    order_cycle { OrderCycle.first || FactoryGirl.create(:simple_order_cycle) }
    sender      { incoming ? FactoryGirl.create(:enterprise) : order_cycle.coordinator }
    receiver    { incoming ? order_cycle.coordinator : FactoryGirl.create(:enterprise) }
  end

  FactoryGirl.modify do
    factory :product do
      primary_taxon { Spree::Taxon.first || FactoryGirl.create(:taxon) }
    end
  end

  factory :enterprise_role do
  end
end
