require 'rails_helper'

describe ReportsController do
  describe '#index' do
    context 'when the user is not authenticated' do
      it 'does not return 200 HTTP status' do
        expect(get(:index)).not_to have_http_status(:ok)
      end
    end

    context 'when the user is authenticated' do
    end

    it 'renders the :index template' do
      expect(get(:index)).to render_template(:index)
    end
  end
end
