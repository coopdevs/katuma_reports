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
            "<select id=\"order_cycle_id\" name=\"order_cycle_id\">"
          )
          expect(response.body).to include(
            "<option value=\"#{monthly_order_cycle.id}\">#{monthly_order_cycle.name}</option>"
          )
          expect(response.body).not_to include(
            "<option value=\"#{weekly_order_cycle.id}\">#{weekly_order_cycle.name}</option>"
          )
        end

        it 'redirects to reports/variants_by_order' do
          get :index
          expect(response.body).to include(
            "<form accept-charset=\"UTF-8\" action=\"/admin/reports/variants_by_order\" method=\"get\">"
          )
        end

        it 'lets the user render the report' do
          get :index
          expect(response.body).to include(
            "<input name=\"commit\" type=\"submit\" value=\"Submit\" />"
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
end
