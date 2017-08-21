FactoryGirl.define do
  sequence(:random_email)       { Faker::Internet.email }
  sequence :user_authentication_token do |n|
    "xxxx#{Time.now.to_i}#{rand(1000)}#{n}xxxxxxxxxxxxx"
  end

  factory :user, class: Spree.user_class do
    email { generate(:random_email) }
    login { email }
    password 'secret'
    password_confirmation { password }
    authentication_token { generate(:user_authentication_token) } if Spree.user_class.attribute_method? :authentication_token

    factory :admin_user do
      spree_roles { [Spree::Role.find_by_name('admin') || create(:role, name: 'admin')] }
    end
  end

  factory :enterprise, class: Enterprise do
    owner { FactoryGirl.create :user }
    sequence(:name) { |n| "Enterprise #{n}" }
    sells 'any'
    description 'enterprise'
    long_description '<p>Hello, world!</p><p>This is a paragraph.</p>'
    email 'enterprise@example.com'
    address { FactoryGirl.create(:address) }
    confirmed_at { Time.zone.now }
    permalink 'zzz'
  end

  factory :address, aliases: [:bill_address, :ship_address], class: Spree::Address do
    firstname 'John'
    lastname 'Doe'
    company 'Company'
    address1 '10 Lovely Street'
    address2 'Northwest'
    city 'Herndon'
    zipcode '20170'
    phone '123-456-7890'
    alternative_phone '123-456-7899'

    state { |address| address.association(:state) }
    country do |address|
      if address.state
        address.state.country
      else
        address.association(:country)
      end
    end
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

  factory :order_cycle, :parent => :simple_order_cycle do
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
      ExchangeFee.create!(exchange: ex1,
                          enterprise_fee: create(:enterprise_fee, enterprise: ex1.sender))
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

      # Products with images
      [ex1, ex2].each do |exchange|
        product = create(:product, supplier: exchange.sender)
        image = File.open(File.expand_path('../../app/assets/images/logo-white.png', __FILE__))
        Spree::Image.create({:viewable_id => product.master.id, :viewable_type => 'Spree::Variant', :alt => "position 1", :attachment => image, :position => 1})

        exchange.variants << product.variants.first
      end

      variants = [ex1, ex2].map(&:variants).flatten
      [ex3, ex4].each do |exchange|
        variants.each { |v| exchange.variants << v }
      end
    end
  end

  factory :state, class: Spree::State do
    name 'Alabama'
    abbr 'AL'
    country do |country|
      if usa = Spree::Country.find_by_numcode(840)
        country = usa
      else
        country.association(:country)
      end
    end
  end

  factory :country, class: Spree::Country do
    iso_name 'UNITED STATES'
    name 'United States of America'
    iso 'US'
    iso3 'USA'
    numcode 840
  end

  factory :enterprise_fee, :class => EnterpriseFee do
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
end
