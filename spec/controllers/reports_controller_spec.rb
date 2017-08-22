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
      let!(:order_cycle) { create(:order_cycle) }

      before { sign_in(user) }

      it 'renders the :index template' do
        expect(get(:index)).to render_template(:index)
      end

      it 'shows the last 10 order cycles' do
        get :index
        expect(response.body).to include(
          "<option value=\"#{order_cycle.id}\">#{order_cycle.name}</option>"
        )
      end
    end
  end
end
