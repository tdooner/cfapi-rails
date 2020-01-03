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

  describe 'POST add_leader' do
    subject { post :add_leader, params: params }

    let(:brigade) { Brigade.create(name: 'Foo Bar Baz') }
    let(:params) { valid_params }
    let(:valid_params) do
      {
        id: brigade.slug,
        brigade_leader: {
          name: 'John Doe',
          email: 'test@example.com',
        }
      }
    end

    context 'when logged out' do
      it 'redirects home' do
        subject
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when an admin' do
      let(:admin) do
        User.create(email: 'test@example.com',
                    password: 'password',
                    confirmed_at: 1.day.ago,
                    has_salesforce_account: true)
      end

      before { sign_in(admin) }

      it 'creates a new BrigadeLeader' do
        expect { subject }.to change(BrigadeLeader, :count).by(1)
        expect(BrigadeLeader.last.brigade).to eq(brigade)
      end
    end

    context 'when a brigade leader' do
      let(:user) do
        User.create(email: 'test@example.com',
                    password: 'password',
                    confirmed_at: 1.day.ago)
      end
      let(:brigade_leader) do
        BrigadeLeader.create(
          name: 'Testy McTestLeader',
          email: user.email,
          brigade: brigade
        )
      end

      before { sign_in(User.find_by(email: brigade_leader.email)) }

      it 'creates a new BrigadeLeader' do
        expect { subject }.to change(BrigadeLeader, :count).by(1)
      end
    end
  end
end
