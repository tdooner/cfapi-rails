# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController do
  render_views

  describe '#show' do
    before { get :show }

    it 'renders' do
      expect(response).to be_successful
      expect(response.body).to include("Brigade Network")
    end
  end
end
