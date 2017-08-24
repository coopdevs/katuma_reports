require 'rails_helper'

describe ReportsController do
  render_views

  before { sign_in(user) }

  describe '#index' do
    context 'when the user is not authenticated' do
      let(:user) { Spree::User.new }

      it 'redirects to the main OFN app' do
        expect(get(:index)).to redirect_to('http://localhost:3000/login')
      end
    end

    context 'when the user is authenticated' do
      let(:user) { create(:user) }
      let(:enterprise) { create(:enterprise) }

      it 'renders the :index template' do
        expect(get(:index)).to render_template(:index)
      end

      context 'when the user belongs to a particular enterprise' do
        let!(:weekly_order_cycle) do
          create(:order_cycle, coordinator: enterprise, created_at: 2.days.ago)
        end
        let!(:monthly_order_cycle) do
          create(:order_cycle, coordinator: enterprise)
        end

        before do
          create(:enterprise_role, user: user, enterprise: enterprise)
          stub_const('ReportsController::SHOWED_ORDER_CYCLES', 1)
        end

        it 'shows its SHOWED_ORDER_CYCLES latest order cycles' do
          get :index
          expect(response.body).to include(
            "<option value=\"#{monthly_order_cycle.id}\">#{monthly_order_cycle.name}</option>"
          )
          expect(response.body).not_to include(
            "<option value=\"#{weekly_order_cycle.id}\">#{weekly_order_cycle.name}</option>"
          )
        end
      end

      context 'when the user does not belong to a particular enterprise' do
        let!(:monthly_order_cycle) do
          create(:order_cycle, coordinator: enterprise)
        end

        it 'does not show its order cycles' do
          get :index
          expect(response.body).not_to include(
            "<option value=\"#{monthly_order_cycle.id}\">#{monthly_order_cycle.name}</option>"
          )
        end
      end
    end
  end

  describe '#show' do
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
    let(:other_variant) { create(:variant) }

    before do
      create(:line_item, order: order, variant: variant, quantity: 4)
      create(:line_item, order: order, variant: other_variant, quantity: 2)
      create(:line_item, order: other_order, variant: other_variant, quantity: 3)
    end

    it 'renders the :show template' do
      expect(get :show, id: order_cycle.id).to render_template(:show)
    end

    it 'shows a column per customer in the order cycle' do
      get :show, id: order_cycle.id

      expect(response.body).to include(
        "<th>#{order.customer.name} - #{order.number}</th>"
      )
      expect(response.body).to include(
        "<th>Guest - #{other_order.number}</th>"
      )
    end

    it 'does not show any column for customers of order cycles of other enterprises' do
      get :show, id: order_cycle.id

      expect(response.body).not_to include(
        "<td>#{order_from_other_enterprise.customer.name}</td>"
      )
    end

    it 'does not show any column for customers of other order cycles of the same enterprise' do
      get :show, id: order_cycle.id

      expect(response.body).not_to include(
        "<td>#{order_from_previous_order_cycle.customer.name}</td>"
      )
    end

    it 'shows a row per variant in the orders of the order cycle' do
      get :show, id: order_cycle.id

      expect(response.body).to include(<<-HTML)
    <tr>
      <td>#{variant.product.name} - Variant: #{variant.id}</td>
      <td>4</td>
      <td>0</td>
    </tr>
      HTML

      expect(response.body).to include(<<-HTML)
    <tr>
      <td>#{other_variant.product.name} - Variant: #{other_variant.id}</td>
      <td>2</td>
      <td>3</td>
    </tr>
      HTML
    end
  end
end
