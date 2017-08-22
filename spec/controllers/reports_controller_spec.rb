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

      before { sign_in(user) }

      it 'renders the :index template' do
        expect(get(:index)).to render_template(:index)
      end

      context 'when the user belongs to a particular enterprise' do
        let(:enterprise) { create(:enterprise) }
        let!(:order_cycle) { create(:order_cycle, coordinator: enterprise) }

        before { create(:enterprise_role, user: user, enterprise: enterprise) }

        it 'shows their order cycles' do
          get :index
          expect(response.body).to include(
            "<option value=\"#{order_cycle.id}\">#{order_cycle.name}</option>"
          )
        end
      end

      context 'when the user does not belong to a particular enterprise' do
        let(:other_user) { create(:user) }
        let(:other_enterprise) { create(:enterprise) }
        let!(:other_order_cycle) do
          create(:order_cycle, coordinator: other_enterprise)
        end

        before do
          create(:enterprise_role, user: other_user, enterprise: other_enterprise)
        end

        it 'does not show their order cycles' do
          get :index
          expect(response.body).not_to include(
            "<option value=\"#{other_order_cycle.id}\">#{other_order_cycle.name}</option>"
          )
        end
      end
    end
  end
end
