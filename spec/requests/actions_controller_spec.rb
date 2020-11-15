require 'rails_helper'

describe continous-days-visited::ActionsController do
  before do
    Jobs.run_immediately!
  end

  it 'can list' do
    sign_in(Fabricate(:user))
    get "/continous-days-visited/list.json"
    expect(response.status).to eq(200)
  end
end
