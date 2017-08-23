require 'rails_helper'

describe ReportsController do
  render_views

  describe '#index' do
    context 'when the user is not authenticated' do
      it 'redirects to the main OFN app' do
        expect(get(:index)).to redirect_to('http://localhost:3000/login')
      end
    end

    context 'when the user is authenticated' do
      let(:user) { create(:user) }
      let(:enterprise) { create(:enterprise) }

      before { sign_in(user) }

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
    let(:user) { create(:user) }
    let(:customer) { create(:customer) }
    let(:other_customer) { create(:customer) }

    let(:user_from_other_enterprise) { create(:user) }

    let(:enterprise) { create(:enterprise) }
    let(:order_cycle) { create(:order_cycle, coordinator: enterprise) }
    let!(:order) do
      create(:order, customer: customer, order_cycle: order_cycle, state: 'complete')
    end
    let!(:other_order) do
      create(:order, customer: other_customer, order_cycle: order_cycle, state: 'complete')
    end

    let(:other_enterprise) { create(:enterprise) }

    before do
      create(
        :enterprise_role,
        user: user_from_other_enterprise,
        enterprise: other_enterprise
      )

      sign_in(user)
    end

    it 'renders the :show template' do
      expect(get :show, id: order_cycle.id).to render_template(:show)
    end

    it 'shows a column per order in the order cycle' do
      get :show, id: order_cycle.id

      expect(response.body).to include("<th>#{order.customer.name}</th>")
      expect(response.body).to include("<th>#{other_order.customer.name}</th>")
    end

    it 'does not show enterprise roles for other order cycles' do
      get :show, id: order_cycle.id

      expect(response.body).not_to include(
        "<td>#{user_from_other_enterprise.login}</td>"
      )
    end
  end
end
