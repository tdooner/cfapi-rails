require 'rails_helper'

RSpec.describe BrigadeController, type: :controller do
  render_views

  describe "GET #show" do
    let(:brigade) { Brigade.create(name: 'Foo Bar Baz') }

    it "returns http success" do
      get :show, params: { id: brigade.to_param }

      expect(response).to have_http_status(:success)
    end
  end
end
