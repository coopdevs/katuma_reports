require 'rails_helper'

describe VariantsByOrderController do
  render_views

  describe '#index' do
    # TODO: Missing authorization. Only a user that belongs to the enterprise
    # can see its reports.
    let(:user) { create(:user) }

    let(:enterprise) { create(:enterprise) }
    let(:order_cycle) { create(:order_cycle, coordinator: enterprise) }

    let(:customer) { create(:customer, name: 'Customer Name') }
    let(:order) do
      create(:order, customer: customer, order_cycle: order_cycle, state: 'complete')
    end

    let(:other_customer) { create(:customer) }
    let!(:other_order) do
      create(:order, customer: other_customer, order_cycle: order_cycle, state: 'complete')
    end

    let(:previous_order_cycle) { create(:order_cycle, coordinator: enterprise) }
    let!(:order_from_previous_order_cycle) do
      create(:order, customer: customer, order_cycle: previous_order_cycle, state: 'complete')
    end

    let(:customer_from_other_enterprise) { create(:customer) }
    let(:other_enterprise) { create(:enterprise) }
    let(:order_cycle_from_other_enterprise) { create(:order_cycle, coordinator: other_enterprise) }
    let!(:order_from_other_enterprise) do
      create(
        :order,
        customer: customer_from_other_enterprise,
        order_cycle: order_cycle_from_other_enterprise,
        state: 'complete'
      )
    end

    let(:variant) { create(:variant) }

    let(:other_product) do
      create(:product, variant_unit: 'weight', variant_unit_scale: 1)
    end
    let(:other_variant) { create(:variant, product: other_product) }

    before do
      create(:line_item, order: order, variant: variant, quantity: 4)
      create(:line_item, order: order, variant: other_variant, quantity: 2)
      create(:line_item, order: other_order, variant: other_variant, quantity: 3)
    end

    it 'renders the :index template' do
      expect(get :index, order_cycle_id: order_cycle.id.to_s)
        .to render_template(:index)
    end

    it 'shows a column with the units of the product' do
      get :index, order_cycle_id: order_cycle.id.to_s
      expect(response.body).to include('<td class="align-center">g</td>')
    end

    it 'shows a column per customer in the order cycle' do
      get :index, order_cycle_id: order_cycle.id.to_s

      expect(response.body).to include(
        "<th>#{order.customer.name} - #{order.number}</th>"
      )
      expect(response.body).to include(
        "<th>Guest - #{other_order.number}</th>"
      )
    end

    it 'does not show any column for customers of order cycles of other enterprises' do
      get :index, order_cycle_id: order_cycle.id

      expect(response.body).not_to include(
        "<td>#{order_from_other_enterprise.customer.name}</td>"
      )
    end

    it 'does not show any column for customers of other order cycles of the same enterprise' do
      get :index, order_cycle_id: order_cycle.id

      expect(response.body).not_to include(
        "<td>#{order_from_previous_order_cycle.customer.name}</td>"
      )
    end

    it 'shows a row per variant in the orders of the order cycle' do
      get :index, order_cycle_id: order_cycle.id.to_s

      expect(response.body).to include(<<-HTML)
      <td class="align-left">#{variant.product.name} - Variant: #{variant.id}</td>
      <td class="align-center"></td>
      <td class="align-right">4</td>
      <td class="align-right">0</td>
    </tr>
      HTML

      expect(response.body).to include(<<-HTML)
      <td class="align-left">#{other_variant.product.name} - Variant: #{other_variant.id}</td>
      <td class="align-center">g</td>
      <td class="align-right">2</td>
      <td class="align-right">3</td>
    </tr>
      HTML
    end
  end
end
