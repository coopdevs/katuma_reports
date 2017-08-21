require 'rails_helper'

describe ReportsController do
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
    end
  end
end
